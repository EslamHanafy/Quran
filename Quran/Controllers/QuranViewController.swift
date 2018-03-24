//
//  QuranViewController.swift
//  Quran
//
//  Created by Eslam on 3/22/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var textView: UITextView!
    
    var surah: Surah!
    var allAyah: [Ayah] = []
    
    let INDEX_ATTRIBUTE: String = "VersIndex"
    let myString = NSMutableAttributedString(string: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allAyah = DBHelper.shared.getAllAyah(forSurah: surah)
        
        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .right
        style.lineBreakMode = .byWordWrapping
        style.lineSpacing = 5
        
        let style2: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style2.alignment = .center
        style2.lineBreakMode = .byWordWrapping
        style2.lineSpacing = 8
        
        let font = UIFont(name: "DecoTypeThuluthII", size: 26)!
        let mid = font.descender + font.capHeight
        
        myString.append(NSAttributedString(string: "سورة " + self.surah.name + "\n", attributes: [
            NSAttributedStringKey.font: UIFont(name: "DiwaniBent", size: 40)!,
            NSAttributedStringKey.paragraphStyle: style2
            ]))
        
        for ayah in allAyah {
            myString.append(NSAttributedString(string: ayah.content , attributes: [
                NSAttributedStringKey.init(INDEX_ATTRIBUTE) : ayah.id,
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.paragraphStyle: style
                ]))
            
            myString.append(NSAttributedString(string: "  "))
            
            let attach = NSTextAttachment()
            attach.image = resizeImage(image: #imageLiteral(resourceName: "number_5"), targetSize: CGSize(width: 30, height: 30))
            attach.bounds = CGRect(x: 0, y: font.descender - 15 / 2 + mid + 2, width: 30, height: 30)
            
            myString.append(NSAttributedString(attachment: attach))
            
            myString.append(NSAttributedString(string: "  "))
        }
        
        textView.attributedText = myString
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(myMethodToHandleTap(_:)))
        tap.delegate = self
        textView.addGestureRecognizer(tap)
    
    }
    
    
    //MARK: - IBAction
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Helpers
extension QuranViewController {
    
    @objc func myMethodToHandleTap(_ sender: UITapGestureRecognizer)
    {
        
        
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        
        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < myTextView.textStorage.length {
            
            // print the character index
            print("character index: \(characterIndex)")
            
            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (myTextView.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")
            
            // check if the tap location has a certain attribute
            let attributeValue = myTextView.attributedText.attribute(NSAttributedStringKey.init(INDEX_ATTRIBUTE), at: characterIndex, effectiveRange: nil) as? Int
            if let value = attributeValue {
                print("You tapped on Vers number: \(value)")
                changeColorForVers(withNumber: value)
            }
        }
    }
    
    func frameOftext(inRange range: NSRange) -> CGRect {
        let beginning = textView.beginningOfDocument
        let start = textView.position(from: beginning, offset: range.location)
        let end = textView.position(from: start!, offset: range.length)
        let textRange = textView.textRange(from: start!, to: end!)
        let rect = textView.firstRect(for: textRange!)
        return textView.convert(rect, from: textView.textInputView)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func changeColorForVers(withNumber number: Int) {
        let range = (textView.attributedText.string as NSString).range(of: allAyah[allAyah.index(where: { $0.id == number })!].content)
        myString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
        textView.attributedText = myString
        
        /*let newRange = (versesString as NSString).range(of: verses[number] + " \(number + 1) ")
         myString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.lightGray], range: newRange)
         
         for i in 0...verses.count-1
         {
         if i != number
         {
         let newRange = (versesString as NSString).range(of: verses[i] + " \(i + 1) ")
         myString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.backgroundColor: UIColor.clear], range: newRange)
         }
         }
         textView.attributedText = myString*/
    }

}
