//
//  Backups.swift
//  Quran
//
//  Created by Eslam on 3/22/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation


/*
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
 
 */



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




















// new backups eslem
/*
 
 
 //
 //  DBHelper.swift
 //  Quran
 //
 //  Created by Eslam Hanafy on 3/20/18.
 //  Copyright © 2018 magdsoft. All rights reserved.
 //
 
 import Foundation
 import SQLite
 
 class DBHelper {
 public static let shared: DBHelper = DBHelper()
 
 fileprivate let db = try! Connection(Bundle.main.path(forResource: "Quran", ofType: "db")!)
 
 
 /// return all surah from database
 ///
 /// - Returns: array of Surah
 func getAllSurah()-> [Surah] {
 var allSurah: [Surah] = []
 
 let surahTable = Table("surah")
 let id = Expression<Int64>("id")
 let name = Expression<String>("name")
 
 do {
 let data = try db.prepare(surahTable)
 for surah in data {
 allSurah.append(Surah(id: Int(surah[id]), name: surah[name], allAyah: []))
 }
 }catch {
 print("the error in getting surah is: \(error.localizedDescription)")
 }
 
 return allSurah
 }
 
 
 /// get all juz from database
 ///
 /// - Returns: array of Juz
 func getAllJuz() -> [Juz] {
 var allJuz: [Juz] = []
 
 let juzTable = Table("juz")
 let surahTable = Table("surah")
 let id = Expression<Int64>("id")
 let surahId = Expression<Int64>("surah_id")
 let ayah = Expression<Int64>("ayah_number")
 let name = Expression<String>("name")
 
 let query = juzTable.join(surahTable, on: surahId == surahTable[id])
 
 do {
 let data = try db.prepare(query)
 for row in data {
 allJuz.append(Juz(id: Int(row[juzTable[id]]), name: row[juzTable[name]], surah: Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: []), ayah: Ayah(id: Int(row[juzTable[ayah]]), content: "")))
 }
 } catch {
 print("the error in getting juz is: \(error.localizedDescription)")
 }
 
 return allJuz
 }
 
 func getAllAyah(forSurah surah: Surah) -> [Ayah] {
 var allAyah: [Ayah] = []
 
 let ayahTable = Table("ayah")
 let surahId = Expression<Int64>("surah_id")
 let number = Expression<Int64>("number")
 let text = Expression<String>("text")
 
 do {
 let data = try db.prepare(ayahTable.where(surahId == Int64(surah.id)))
 for row in data {
 allAyah.append(Ayah(id: Int(row[number]), content: row[text]))
 }
 } catch {
 print("the error in getting all ayah is: \(error.localizedDescription)")
 }
 
 return allAyah
 }
 
 
 func getAllPages() -> [Page] {
 var pages: [Page] = []
 
 //tables
 let surahTable = Table("surah")
 let pagesTable = Table("pages")
 // columns
 let surahId = Expression<Int64>("surah_id")
 let id = Expression<Int64>("id")
 let ayah = Expression<Int64>("ayah_number")
 let name = Expression<String>("name")
 
 
 do {
 let data = try db.prepare(pagesTable.join(surahTable, on: pagesTable[surahId] == surahTable[id]))
 
 for (index, row) in data.enumerated() {
 print("the current index is: \(index)")
 let sura = Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: [])
 pages.append(Page(id: Int(row[pagesTable[id]]), startIngAyah: Int(row[pagesTable[ayah]]), juz: self.getJuz(forSurah: sura), allSurah: []))
 }
 
 } catch {
 print("the error in gitting pages is: \(error.localizedDescription)")
 }
 
 
 return pages
 }
 
 
 private func getAllAyah(forPages pages: inout [Page]) -> [Page] {
 /*if let next = data.first(where: { $0[pagesTable[id]] == (row[pagesTable[id]] + 1) }) {
 allSurah = getAllAyahInPage(startingFromSurah: row[pagesTable[surahId]], toSurah: next[pagesTable[surahId]], andStartingFromAyah: row[pagesTable[ayah]], toAyah: next[pagesTable[ayah]])
 }else {
 allSurah = getAllAyahInPage(startingFromSurah: row[pagesTable[surahId]], toSurah: 0, andStartingFromAyah: row[pagesTable[ayah]], toAyah: 0)
 }*/
 
 for (index, page) in pages.enumerated() {
 var allSurah: [Surah]!
 
 if index == pages.count - 1 {
 allSurah = getAllAyahInPage(startingFromSurah: Int64(page.juz.surah.id), toSurah: <#T##Int64#>, andStartingFromAyah: <#T##Int64#>, toAyah: <#T##Int64#>)
 }else {
 
 }
 }
 
 return pages
 }
 
 
 func getAllAyahInPage(startingFromSurah startSurah: Int64, toSurah endSurah: Int64, andStartingFromAyah startAyah: Int64, toAyah endAyah: Int64) -> [Surah] {
 var allSurah: [Surah] = []
 
 // tables
 let ayahTable = Table("ayah")
 let surahTable = Table("surah")
 // columns
 let surahId = Expression<Int64>("surah_id")
 let number = Expression<Int64>("number")
 let text = Expression<String>("text")
 let name = Expression<String>("name")
 let id = Expression<Int64>("id")
 
 var query: QueryType!
 
 if startSurah != endSurah {
 query = ayahTable.join(surahTable, on: surahId == surahTable[id]).where( ayahTable[surahId] >= startSurah && ayahTable[surahId] < endSurah && ayahTable[number] >= startAyah && ayahTable[number] < endAyah )
 }else {
 query = ayahTable.join(surahTable, on: surahId == surahTable[id]).where( ayahTable[surahId] == startSurah && ayahTable[number] >= startAyah && ayahTable[number] < endAyah )
 }
 
 
 do {
 let data = try db.prepare(query)
 
 for row in data {
 var sura: Surah!
 
 if let _sura: Surah = allSurah.popLast() {
 if (_sura.allAyah.last?.id ?? 0) > Int(row[ayahTable[number]]) {
 allSurah.append(_sura)
 sura = Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: [])
 }else {
 sura = _sura
 }
 }else {
 sura = Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: [])
 }
 
 sura.allAyah.append(Ayah(id: Int(row[ayahTable[number]]), content: row[ayahTable[text]]))
 allSurah.append(sura)
 }
 
 } catch  {
 print("the error in getting all ayah in page is: \(error.localizedDescription)")
 }
 
 return allSurah
 }
 
 func getJuz(forSurah surah: Surah) -> Juz {
 return Juz(id: 0, name: "", surah: surah, ayah: Ayah(id: 0, content: ""))
 }
 }

 
 */
