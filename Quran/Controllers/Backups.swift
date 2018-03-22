//
//  Backups.swift
//  Quran
//
//  Created by Eslam on 3/22/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation

/*
 
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
 //    var versesString: String = ""
 
 let INDEX_ATTRIBUTE: String = "VersIndex"
 let NUMBER_ATTRIBUTE: String = "NumberIndex"
 let myString = NSMutableAttributedString(string: "")
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 allAyah = DBHelper.shared.getAllAyah(forSurah: surah)
 
 let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
 style.alignment = .right
 style.lineBreakMode = .byWordWrapping
 style.lineSpacing = 5
 
 let font = UIFont(name: "DecoTypeThuluthII", size: 22)!
 let mid = font.descender + font.capHeight
 
 for ayah in allAyah {
 myString.append(NSAttributedString(string: ayah.content , attributes: [
 NSAttributedStringKey.init(INDEX_ATTRIBUTE) : index,
 NSAttributedStringKey.font: font,
 NSAttributedStringKey.paragraphStyle: style
 ]))
 
 myString.append(NSAttributedString(string: "  "))
 
 let attach = NSTextAttachment()
 attach.image = resizeImage(image: #imageLiteral(resourceName: "number_5"), targetSize: CGSize(width: 30, height: 30))
 attach.bounds = CGRect(x: 0, y: font.descender - 15 / 2 + mid + 2, width: 30, height: 30)
 
 myString.append(NSAttributedString(attachment: attach))
 
 myString.append(NSAttributedString(string: "  "))
 
 /*myString.append(NSAttributedString(string: "   \(ayah.id)   ", attributes:[
 NSAttributedStringKey.init(NUMBER_ATTRIBUTE) : index,
 NSAttributedStringKey.font: UIFont(name: "GESSTwoBold-Bold", size: 18)!
 ]))
 
 textView.attributedText = myString
 versesString += ayah.content + "   \(ayah.id)   "
 
 //            if ayah.id == 5 {
 let range = (versesString as NSString).range(of: "   \(ayah.id)   ")
 let frame = frameOftext(inRange: range)
 print("eslam the text rect should be: \(frame)")
 let newImage = UIImageView(frame: frame)
 newImage.clipsToBounds = true
 newImage.contentMode = .scaleAspectFit
 newImage.image = #imageLiteral(resourceName: "ayahNumber")
 textView.addSubview(newImage)
 textView.sendSubview(toBack: newImage)
 /*let newView = UIView(frame: frame)
 newView.backgroundColor = UIColor.cyan
 textView.addSubview(newView)
 textView.sendSubview(toBack: newView)*/
 //            }
 */
 }
 
 textView.attributedText = myString
 
 let tap = UITapGestureRecognizer(target: self, action: #selector(myMethodToHandleTap(_:)))
 tap.delegate = self
 textView.addGestureRecognizer(tap)
 
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
 
 
 func changeColorForVers(withNumber number: Int) {
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
 
 
 
 /*
 - (CGRect)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView
 {
 UITextPosition *beginning = textView.beginningOfDocument;
 UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
 UITextPosition *end = [textView positionFromPosition:start offset:range.length];
 UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
 CGRect rect = [textView firstRectForRange:textRange];
 return [textView convertRect:rect fromView:textView.textInputView];
 }
 */
 
 func frameOftext(inRange range: NSRange) -> CGRect {
 let beginning = textView.beginningOfDocument
 let start = textView.position(from: beginning, offset: range.location)
 let end = textView.position(from: start!, offset: range.length)
 let textRange = textView.textRange(from: start!, to: end!)
 let rect = textView.firstRect(for: textRange!)
 return textView.convert(rect, from: textView.textInputView)
 }
 
 @IBAction func back() {
 self.dismiss(animated: true, completion: nil)
 }
 
 }
 /*
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
 var versesString: String = ""
 
 let INDEX_ATTRIBUTE: String = "VersIndex"
 let NUMBER_ATTRIBUTE: String = "NumberIndex"
 let myString = NSMutableAttributedString(string: "")
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 allAyah = DBHelper.shared.getAllAyah(forSurah: surah)
 
 let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
 style.alignment = .center
 style.lineBreakMode = .byWordWrapping
 style.lineSpacing = 8
 
 /*
 myString.append(NSAttributedString(string: self.surah.name + "\n", attributes: [
 NSAttributedStringKey.font: UIFont(name: "DecoTypeThuluthII", size: 22)!,
 NSAttributedStringKey.paragraphStyle: style
 ]))
 
 textView.attributedText = myString
 versesString = self.surah.name + "\n"
 
 
 let nameImage = UIImageView(frame: frameOftext(inRange: (versesString as NSString).range(of: versesString)))
 nameImage.image = #imageLiteral(resourceName: "surah")
 textView.addSubview(nameImage)
 textView.sendSubview(toBack: nameImage)
 */
 let style2: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
 style.alignment = .right
 style.lineBreakMode = .byWordWrapping
 style.lineSpacing = 4
 
 for ayah in allAyah {
 myString.append(NSAttributedString(string: ayah.content , attributes: [
 NSAttributedStringKey.init(INDEX_ATTRIBUTE) : index,
 NSAttributedStringKey.font: UIFont(name: "DecoTypeThuluthII", size: 22)!,
 NSAttributedStringKey.paragraphStyle: style2
 ]))
 
 myString.append(NSAttributedString(string: " \(ayah.id) ", attributes:[
 NSAttributedStringKey.init(NUMBER_ATTRIBUTE) : index,
 NSAttributedStringKey.font: UIFont(name: "GESSTwoBold-Bold", size: 22)!
 ]))
 
 textView.attributedText = myString
 versesString += ayah.content + " \(ayah.id) "
 
 let range = (versesString as NSString).range(of: " \(ayah.id) ")
 let frame = frameOftext(inRange: range)
 print("eslam the text rect should be: \(frame)")
 let numberImage = UIImageView(frame: frame)
 numberImage.image = #imageLiteral(resourceName: "ayahNumber")
 textView.addSubview(numberImage)
 textView.sendSubview(toBack: numberImage)
 
 }
 
 
 
 let tap = UITapGestureRecognizer(target: self, action: #selector(myMethodToHandleTap(_:)))
 tap.delegate = self
 textView.addGestureRecognizer(tap)
 
 }
 
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
 
 
 func changeColorForVers(withNumber number: Int) {
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
 
 
 
 /*
 - (CGRect)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView
 {
 UITextPosition *beginning = textView.beginningOfDocument;
 UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
 UITextPosition *end = [textView positionFromPosition:start offset:range.length];
 UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
 CGRect rect = [textView firstRectForRange:textRange];
 return [textView convertRect:rect fromView:textView.textInputView];
 }
 */
 
 func frameOftext(inRange range: NSRange) -> CGRect {
 let beginning = textView.beginningOfDocument
 let start = textView.position(from: beginning, offset: range.location)
 let end = textView.position(from: start!, offset: range.length)
 let textRange = textView.textRange(from: start!, to: end!)
 let rect = textView.firstRect(for: textRange!)
 return textView.convert(rect, from: textView.textInputView)
 }
 
 @IBAction func back() {
 self.dismiss(animated: true, completion: nil)
 }
 
 }
 
 */

 
 */
