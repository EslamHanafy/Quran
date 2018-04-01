//
//  QuranTextView.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/27/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit


fileprivate enum TextType {
    case header, subheader, normal, number
}

fileprivate struct AyahIndex {
    var ayah: Int
    var surah: Int
    
    init (string: String) {
        let arr = string.split(separator: ",")
        self.ayah = Int(arr[1])!
        self.surah = Int(arr[0])!
    }
    
    init(ayah: Int, surah: Int) {
        self.ayah = ayah
        self.surah = surah
    }
}

class QuranTextView: UITextView {

    fileprivate var allSurah: [Surah] = []
    fileprivate var titleImages: [UIImageView] = []
    
    fileprivate let surahStart: String = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
    fileprivate let invisibleSign: String = "\u{200B}"
    
    fileprivate var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
    fileprivate var gesture: UITapGestureRecognizer? = UITapGestureRecognizer()
    
    fileprivate let INDEX_ATTRIBUTE: String = "AyahIndex"
    fileprivate let SELECTED_ATTRIBUTE: String = "SelectedAyah"
    fileprivate let mainFont: UIFont = UIFont(name: "KFGQPCUthmanTahaNaskh-Bold", size: isIpadScreen ? 42 : 21)!
    fileprivate let subFont: UIFont = UIFont(name: "KFGQPCUthmanicScriptHAFS", size: isIpadScreen ? 36 : 18)!
    fileprivate let numFont: UIFont = UIFont(name: "KFGQPCUthmanicScriptHAFS", size: isIpadScreen ? 44 : 22)!
    
    
    func initWith(surah: [Surah]) {
        self.allSurah = surah
        
        initTextView()
    }
    
    func preapareForReuse() {
        allSurah.removeAll()
        attributedString = NSMutableAttributedString(string: "")
        self.attributedText = attributedString
        self.removeGestureRecognizer(gesture!)
        titleImages.forEach({ $0.removeFromSuperview() })
        titleImages.removeAll()
    }
}

//MARK: - Helpers
extension QuranTextView {
    
    fileprivate func initTextView() {
        self.isEditable = false
        self.isSelectable = false
        
        for (index, sura) in allSurah.enumerated() {
            add(surah: sura, atIndex: index)
        }
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.textViewTapHandler(_:)))
        gesture!.delegate = self
        self.addGestureRecognizer(gesture!)
    }
    
    fileprivate func getStyle(forType type: TextType) -> NSMutableParagraphStyle {
        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = type == .normal || type == .number ? NSTextAlignment.justified : .center
        style.lineBreakMode = .byWordWrapping
        style.firstLineHeadIndent = 1
        style.lineSpacing = type == .normal || type == .number ? 3 : type == .header ? 5 : 4
        style.baseWritingDirection = .rightToLeft
        return style
    }
    
    fileprivate func add(surah: Surah, atIndex surahIndex: Int) {
        for (index, ayah) in surah.allAyah.enumerated() {
            //check for the first ayah
            if ayah.id == 1 {
                if surahIndex != 0 {
                    attributedString.append(NSAttributedString(string: "\n"))
                }
                //add the surah name
                attributedString.append(NSAttributedString(string: "سورة " + surah.name, attributes: getAttributes(forType: .header, atIndex: AyahIndex(ayah: 0, surah: surahIndex))))
                
                attributedString.append(NSAttributedString(string: "\n"))
                
                //check if it's for first surah in quran
                if surah.id == 1 {
                    attributedString.append(NSAttributedString(string: invisibleSign + ayah.content + invisibleSign, attributes: getAttributes(forType: .normal, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
                }else {
                    //it's not the first surah, so we need to split the surah start from it
                    attributedString.append(NSAttributedString(string: invisibleSign + surahStart + invisibleSign, attributes: getAttributes(forType: .subheader, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
                    
                    attributedString.append(NSAttributedString(string: "\n"))
                    
                    attributedString.append(NSAttributedString(string: invisibleSign + String(ayah.content.dropFirst(surahStart.count + 1)) + invisibleSign, attributes: getAttributes(forType: .normal, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
                }
            }else {
                // it's not the first ayah
                attributedString.append(NSAttributedString(string: invisibleSign + ayah.content + invisibleSign, attributes: getAttributes(forType: .normal, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
            }
            
            //adding the ayah number
            attributedString.append(NSAttributedString(string: " \(getValidatedNumber(fromInt: Int(ayah.id))) ", attributes: getAttributes(forType: .number, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
        }
        
        self.attributedText = attributedString
    }
    
    fileprivate func getAttributes(forType type: TextType, atIndex index: AyahIndex) -> [NSAttributedStringKey: Any] {
        if type == .header {
            return [NSAttributedStringKey.font: mainFont, NSAttributedStringKey.paragraphStyle: getStyle(forType: type)]
        }
        
        return [NSAttributedStringKey.font: type == .number ? numFont : subFont, NSAttributedStringKey.paragraphStyle: getStyle(forType: type), NSAttributedStringKey.init(INDEX_ATTRIBUTE): "\(index.surah),\(index.ayah)"]
    }
    
    
    fileprivate func selectAyah(atIndex index: AyahIndex) {
        changeAyahColor(atIndex: index)
        
        //show ayah here eslam
        let rect = self.convert(frameOftext(inRange: getRangeForAyah(atIndex: index), usingFirstFrame: true), to: nil)
        QuranViewController.ayahOptions?.show(optionsForAyah: allSurah[index.surah].allAyah[index.ayah], atLocation: CGPoint(x: rect.midX, y: rect.minY - 10))
        self.attributedText = attributedString
        
    }
    
    fileprivate func changeAyahColor(atIndex index: AyahIndex) {
        //remove old color
        attributedString.removeAttribute(NSAttributedStringKey.foregroundColor, range: NSMakeRange(0, self.textStorage.length))
        self.attributedText = attributedString
        
        attributedString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.brown], range: getRangeForAyah(atIndex: index))
        
        self.attributedText = attributedString
    }
    
    fileprivate func getRangeForAyah(atIndex index: AyahIndex) -> NSRange {
        var newRange: NSRange!
        
        if allSurah[index.surah].id != 1 && allSurah[index.surah].allAyah[index.ayah].id == 1 {
            //get range for the first ayah that we split it before adding it
            newRange = (attributedString.string as NSString).range(of: invisibleSign + String(allSurah[index.surah].allAyah[index.ayah].content.dropFirst(surahStart.count + 1)) + invisibleSign + " \(getValidatedNumber(fromInt: Int(allSurah[index.surah].allAyah[index.ayah].id))) ")
        }else {
            newRange = (attributedString.string as NSString).range(of: invisibleSign + allSurah[index.surah].allAyah[index.ayah].content + invisibleSign + " \(getValidatedNumber(fromInt: Int(allSurah[index.surah].allAyah[index.ayah].id))) ")
        }
        
        return newRange
    }
    
    fileprivate func frameOftext(inRange range: NSRange, usingFirstFrame useFirst: Bool = false) -> CGRect {
        let beginning = self.beginningOfDocument
        let start = self.position(from: beginning, offset: range.location)
        let end = self.position(from: start!, offset: range.length)
        let textRange = self.textRange(from: start!, to: end!)
        
        var selectedRect: CGRect!
        
        if useFirst {
            for selectionRects in self.selectionRects(for: textRange!) {
                let rect = (selectionRects as! UITextSelectionRect).rect
                if selectedRect == nil {
                    selectedRect = rect
                }else{
                    if rect.width > selectedRect.width {
                        selectedRect = rect
                    }
                }
            }
        }else {
            selectedRect = self.firstRect(for: textRange!)
        }

        return self.convert(selectedRect, from: self.textInputView)
    }
    
    
    fileprivate func addImage(forSurah surah: Surah) {
        self.setNeedsDisplay()
        
        let range = (attributedString.string as NSString).range(of: "سورة " + surah.name)
        let textFrame = frameOftext(inRange: range, usingFirstFrame: true)
        let padding: CGFloat = 55
        var imageFrame = textFrame
        imageFrame.origin.x -= padding
        imageFrame.origin.y -= padding + 2
        imageFrame.size.width += padding * 2
        imageFrame.size.height += padding * 2
        
        let image = UIImageView(frame: imageFrame)
        image.image = UIImage(named: "title")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        
        self.addSubview(image)
        self.sendSubview(toBack: image)
        titleImages.append(image)
    }
    
    func updateTitleImages() {
        titleImages.forEach({ $0.removeFromSuperview() })
        titleImages.removeAll()
        
        for surah in allSurah {
            if surah.allAyah.first?.id == 1 {
                addImage(forSurah: surah)
            }
        }
        
        self.attributedText = attributedString
    }
}

//MARK: - GestureRecognizer
extension QuranTextView: UIGestureRecognizerDelegate {
    
    @objc fileprivate func textViewTapHandler(_ sender: UITapGestureRecognizer) {
        
        let layoutManager = self.layoutManager
        
        // location of tap in self coordinates and taking the inset into account
        var location = sender.location(in: self)
        location.x -= self.textContainerInset.left;
        location.y -= self.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < self.textStorage.length {
            
            // print the character index
            print("character index: \(characterIndex)")
            /*
            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (self.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")
            */
            // check if the tap location has a certain attribute
            let attributeValue = self.attributedText.attribute(NSAttributedStringKey.init(INDEX_ATTRIBUTE), at: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                print("You tapped on ayah number: \(value)")
                selectAyah(atIndex: AyahIndex(string: value))
            }
        }
    }
}
