//
//  QuranTextView.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/27/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranTextView: UITextView {

    fileprivate var page: Page!
    fileprivate var titleImages: [UIImageView] = []
    
    
    fileprivate var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
    fileprivate var gesture: UITapGestureRecognizer? = UITapGestureRecognizer()
    
    /// that last selected text range
    fileprivate var lastRange: NSRange? = nil
    
    
    /// init the QuranTextView with the given page
    ///
    /// - Parameter page: Page object that contain the page data
    func initWith(page: Page) {
        self.page = page
        
        initTextView()
    }
    
    
    /// reset QuranTextView values
    func preapareForReuse() {
        attributedString = NSMutableAttributedString(string: "")
        self.attributedText = attributedString
        self.removeGestureRecognizer(gesture!)
        titleImages.forEach({ $0.removeFromSuperview() })
        titleImages.removeAll()
        lastRange = nil
    }
}

//MARK: - Helpers
extension QuranTextView {
    
    /// init the text view
    fileprivate func initTextView() {
        self.isEditable = false
        self.isSelectable = false
        
        mainQueue {
            //get the attributed string from quran manager
            self.attributedString = QuranManager.manager.getAttributedText(forPage: self.page)
            self.attributedText = self.attributedString
            self.updateTitleImages()
        }
        
        // add the UITapGestureRecognizer
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.textViewTapHandler(_:)))
        gesture!.delegate = self
        self.addGestureRecognizer(gesture!)
    }
    
    
    
    /// update all surah title background images
    func updateTitleImages() {
        titleImages.forEach({ $0.removeFromSuperview() })
        titleImages.removeAll()
        
        for surah in page.getAllSurah() {
            if surah.allAyah.first?.id == 1 {
                titleImages.append(QuranManager.manager.addTitleImage(forSurah: surah, atTextView: self))
            }
        }
        
        self.attributedText = attributedString
    }
    
    
    /// get Ayah index for the given ayah
    ///
    /// - Parameter ayah: the ayah that you want to get it's index
    /// - Returns: AyahIndex object that represent the given ayah
    fileprivate func getIndex(forAyah ayah: Ayah) -> AyahIndex {
        for (surahIndex, surah) in page.getAllSurah().enumerated() {
            for (ayahIndex, _ayah) in surah.allAyah.enumerated() {
                if _ayah === ayah {
                    return AyahIndex(ayah: ayahIndex, surah: surahIndex, page: Int(page.id - 1))
                }
            }
        }
        
        return AyahIndex(ayah: 0, surah: 0, page: 0)
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
            // check if the tap location has a certain attribute
            let attributeValue = self.attributedText.attribute(QuranManager.manager.INDEX_ATTRIBUTE, at: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                print("You tapped on ayah number: \(value)")
                selectAyah(atIndex: AyahIndex(string: value))
            }
        }
    }
}

//MARK: - Selection
extension QuranTextView {
    
    /// select ayah at the given index
    ///
    /// - Parameter index: the ayah index
    fileprivate func selectAyah(atIndex index: AyahIndex) {
        QuranViewController.ayahOptions?.onHideOptionsView = self.handleHideActionForAyah(_:)
        QuranViewController.ayahOptions?.onMarkAyah = self.handleMarkActionForAyah(_:)
        
        let rect = self.convert(QuranManager.manager.frameOftext(inTextView: self, atRange: QuranManager.manager.getRangeForAyah(atIndex: index, fromTextView: self)), to: nil)
        
        QuranViewController.ayahOptions?.show(optionsForAyah: page.getAllSurah()[index.surah].allAyah[index.ayah], atLocation: CGPoint(x: rect.midX, y: rect.minY - 10))
        
        changeAyahColor(atIndex: index)
    }
    
    
    /// change forground color for the ayah at the given index
    ///
    /// - Parameter index: ayah index
    fileprivate func changeAyahColor(atIndex index: AyahIndex) {
        if page.getAllSurah()[index.surah].allAyah[index.ayah].isBookmarked {
            return
        }
        
        let range = QuranManager.manager.getRangeForAyah(atIndex: index, fromTextView: self)
        attributedString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.brown], range: range)
        lastRange = range
        
        self.attributedText = attributedString
    }
    
    
    /// remove the last selection effect
    fileprivate func removeLastSelection() {
        if let range = lastRange {
            self.attributedString.removeAttribute(NSAttributedStringKey.foregroundColor, range: range)
            self.attributedText = attributedString
        }
    }
}

//MARK: - AyahOptions handler
extension QuranTextView {
    
    /// handle the bookmark action
    ///
    /// - Parameter ayah: the ayah that should be updated
    fileprivate func handleMarkActionForAyah(_ ayah: Ayah) {
        let range =  QuranManager.manager.getRangeForAyah(atIndex: getIndex(forAyah: ayah), fromTextView: self)
        
        if ayah.isBookmarked {
            self.attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
        }else {
            self.attributedString.removeAttribute(NSAttributedStringKey.foregroundColor, range: range)
        }
        
        self.attributedText = attributedString
    }
    
    
    /// handle the play/stop actions for the given ayah
    ///
    /// - Parameter ayah: Ayah object that represent the changed ayah
    func handlePlayActionForAyah(_ ayah: Ayah) {
        let range =  QuranManager.manager.getRangeForAyah(atIndex: getIndex(forAyah: ayah), fromTextView: self)
        
        if ayah.isPlaying {
            self.attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: range)
        }else {
            self.attributedString.removeAttribute(NSAttributedStringKey.foregroundColor, range: range)
        }
        
        self.attributedText = attributedString
    }
    
    /// handle the ayah options hide action
    ///
    /// - Parameter ayah: the selected ayah
    fileprivate func handleHideActionForAyah(_ ayah: Ayah) {
        if ayah.isBookmarked || ayah.isPlaying {
            return
        }
        
        //remove old selection
        removeLastSelection()
    }
}
