//
//  QuranManager+AttributedString.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/3/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

//MARK: - Attributed text
extension QuranManager {
    
    /// The first sentence in each surah
    var surahStart: String { get { return "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ" } }
    
    /// hidden characters that determine the beginning of each ayah
    var beginninInvisibleSign: String { get { return "\u{200B}" } }
    
    /// hidden characters that determine the ending of each ayah
    var endingInvisibleSign: String { get { return "\u{200B}" } }
    
    /// ayah index attribute
    var INDEX_ATTRIBUTE: NSAttributedStringKey { get { return NSAttributedStringKey.init("AyahIndex") } }
    
    /// the surah name font
    fileprivate var titleFont: UIFont { get { return UIFont(name: "KFGQPCUthmanTahaNaskh-Bold", size: isIpadScreen ? 42 : 21)! } }
    
    /// the default ayah font
    fileprivate var ayahFont: UIFont { get { return UIFont(name: "KFGQPCUthmanicScriptHAFS", size: isIpadScreen ? 36 : 18)! } }
    
    /// the default number font
    fileprivate var numberFont: UIFont { get { return UIFont(name: "KFGQPCUthmanicScriptHAFS", size: isIpadScreen ? 44 : 22)! } }
    
    
    /// get attributed string for the given page
    ///
    /// - Parameter page: Page object that contain the page data
    /// - Returns: NSMutableAttributedString that represent this page
    func getAttributedText(forPage page: Page) -> NSMutableAttributedString {
        var attributedString = NSMutableAttributedString(string: "")
        
        for (index, surah) in page.getAllSurah().enumerated() {
            add(surah: surah, atIndex: AyahIndex(ayah: 0, surah: index, page: Int(page.id - 1)), toAttributedString: &attributedString)
        }
        
        return attributedString
    }
    
    
    /// add new surah to the given NSMutableAttributedString
    ///
    /// - Parameters:
    ///   - surah: the surah that you want to add it to the attributed string
    ///   - surahIndex: AyahIndex object that contain the surah index data
    ///   - attributedString: the NSMutableAttributedString that you want to add the given surah to it
    fileprivate func add(surah: Surah, atIndex surahIndex: AyahIndex, toAttributedString attributedString: inout NSMutableAttributedString) {
        for (index, ayah) in surah.allAyah.enumerated() {
            //add current ayah index to the surah index
            let ayahIndex = surahIndex
            ayahIndex.ayah = index
            
            //check for the first ayah
            if ayah.id == 1 {
                //add new line after the last surah if needed
                if surahIndex.surah != 0 {
                    attributedString.append(NSAttributedString(string: "\n\n"))
                }
                
                //add the surah name
                attributedString.append(NSAttributedString(string: "سورة " + surah.name, attributes: getAttributes(forType: .header, atIndex: ayahIndex)))
                
                attributedString.append(NSAttributedString(string: "\n\n"))
                
                //check if it's for first surah in quran
                if surah.id == 1 {
                    attributedString.append(NSAttributedString(string: beginninInvisibleSign + ayah.content + endingInvisibleSign, attributes: getAttributes(forType: .normal, atIndex: ayahIndex)))
                }else {
                    //it's not the first surah, so we need to split the surah start from it
                    attributedString.append(NSAttributedString(string: beginninInvisibleSign + surahStart + endingInvisibleSign, attributes: getAttributes(forType: .subheader, atIndex: ayahIndex)))
                    
                    attributedString.append(NSAttributedString(string: "\n"))
                    
                    attributedString.append(NSAttributedString(string: beginninInvisibleSign + String(ayah.content.dropFirst(surahStart.count + 1)) + endingInvisibleSign, attributes: getAttributes(forType: .normal, atIndex: ayahIndex)))
                }
            }else {
                // it's not the first ayah
                attributedString.append(NSAttributedString(string: beginninInvisibleSign + ayah.content + endingInvisibleSign, attributes: getAttributes(forType: .normal, atIndex: ayahIndex)))
            }
            
            //adding the ayah number
            attributedString.append(NSAttributedString(string: " \(getValidatedNumber(fromInt: Int(ayah.id))) ", attributes: getAttributes(forType: .number, atIndex: ayahIndex)))
        }
    }
    
    
    /// get custom paragraph style for the given text type
    ///
    /// - Parameter type: the QuranTextType for this style
    /// - Returns: NSMutableParagraphStyle for the given style
    fileprivate func getStyle(forType type: QuranTextType) -> NSMutableParagraphStyle {
        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = type == .normal || type == .number ? NSTextAlignment.justified : .center
        style.lineBreakMode = .byWordWrapping
        style.firstLineHeadIndent = 1
        style.lineSpacing = type == .normal || type == .number ? 3 : type == .header ? 5 : 4
        style.baseWritingDirection = .rightToLeft
        return style
    }
    
    
    /// get the needed attributes for the given text type
    ///
    /// - Parameters:
    ///   - type: the QuranTextType for this attributes
    ///   - index: the AyahIndex for this attributes
    /// - Returns: [NSAttributedStringKey: Any]
    fileprivate func getAttributes(forType type: QuranTextType, atIndex index: AyahIndex) -> [NSAttributedStringKey: Any] {
        if type == .header {
            return [NSAttributedStringKey.font: titleFont, NSAttributedStringKey.paragraphStyle: getStyle(forType: type), NSAttributedStringKey.foregroundColor: fontColor]
        }
        
        var attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: type == .number ? numberFont : ayahFont, NSAttributedStringKey.paragraphStyle: getStyle(forType: type), INDEX_ATTRIBUTE: "\(index.surah),\(index.ayah),\(index.page)", NSAttributedStringKey.foregroundColor: fontColor]
        
        if self.pages[index.page].allSurah[index.surah].allAyah[index.ayah].isBookmarked {
            attributes[NSAttributedStringKey.foregroundColor] = UIColor.red
        }
        
        return attributes
    }
}

