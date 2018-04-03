//
//  QuranManager+UITextView.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/3/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

extension QuranManager {
    
    /// get range for ayah at the given index in the given TextView
    ///
    /// - Parameters:
    ///   - index: the ayah index
    ///   - textView: the text view that is displaying this ayah
    /// - Returns: NSRage that represent this ayah
    func getRangeForAyah(atIndex index: AyahIndex, fromTextView textView: UITextView) -> NSRange {
        var newRange: NSRange!
        let surah = self.pages[index.page].getAllSurah()[index.surah]
        
        if surah.id != 1 && surah.allAyah[index.ayah].id == 1 {
            //get range for the first ayah that we split it before adding it
            newRange = (textView.attributedText.string as NSString).range(of: beginninInvisibleSign + String(surah.allAyah[index.ayah].content.dropFirst(surahStart.count + 1)) + endingInvisibleSign + " \(getValidatedNumber(fromInt: Int(surah.allAyah[index.ayah].id))) ")
        }else {
            newRange = (textView.attributedText.string as NSString).range(of: beginninInvisibleSign + surah.allAyah[index.ayah].content + endingInvisibleSign + " \(getValidatedNumber(fromInt: Int(surah.allAyah[index.ayah].id))) ")
        }
        
        return newRange
    }
    
    
    
    /// get the frame that represent the text at the given range
    ///
    /// - Parameters:
    ///   - textView: TextView that is displaying this text
    ///   - range: the text range
    ///   - useFirst: use the first rect or the biggest range (in width), default is false
    /// - Returns: CGRect that represent the text at the given range
    func frameOftext(inTextView textView: UITextView, atRange range: NSRange, usingFirstFrame useFirst: Bool = false) -> CGRect {
        let beginning = textView.beginningOfDocument
        let start = textView.position(from: beginning, offset: range.location)
        let end = textView.position(from: start!, offset: range.length)
        let textRange = textView.textRange(from: start!, to: end!)
        
        var selectedRect: CGRect!
        
        if useFirst {
            selectedRect = textView.firstRect(for: textRange!)
        }else {
            for selectionRects in textView.selectionRects(for: textRange!) {
                let rect = (selectionRects as! UITextSelectionRect).rect
                if selectedRect == nil {
                    selectedRect = rect
                }else{
                    if rect.width > selectedRect.width {
                        selectedRect = rect
                    }
                }
            }
        }
        
        return textView.convert(selectedRect, from: textView.textInputView)
    }
    
    
    /// add the title background image for the given surah
    ///
    /// - Parameters:
    ///   - surah: the surah that you want to add the image for it's title
    ///   - textView: the text view that is displaying this surah
    /// - Returns: UIImageView that represent the title background image
    func addTitleImage(forSurah surah: Surah, atTextView textView: UITextView) -> UIImageView {
        let range = (textView.attributedText.string as NSString).range(of: "سورة " + surah.name)
        let textFrame = self.frameOftext(inTextView: textView, atRange: range)
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
        
        textView.addSubview(image)
        textView.sendSubview(toBack: image)
        
        return image
    }
}
