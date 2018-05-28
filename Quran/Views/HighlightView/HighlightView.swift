//
//  HighlightView.swift
//  Quran
//
//  Created by Eslam on 5/23/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class HighlightView: UIView {

    fileprivate var mainImageView: UIImageView!
    
    fileprivate var imageScale: ImageScale {
        get {
            let size = mainImageView.frame.size
            return ImageScale(width: size.width / 1280.0, height: size.height / 2071)
        }
    }
    
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
    
    fileprivate var page: Page!
    
    fileprivate var highlights: [HighlightedRect] = []
    
    
    
    func initWith(imageView: UIImageView, forPage page: Page) {
        self.mainImageView = imageView
        initGestureRecognizer()
        self.page = page
        addMissingHighlightsForCurrentPage()
    }
    
    
    /// reset the highlights view for reusing it
    func reset() {
        resetHighlights()
        deinitGestureRecognizer()
    }
}

//MARK - GestureRecognizer
extension HighlightView {
    
    /// init TapGestureRecognizer for the first time
    fileprivate func initGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizerAction))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    /// deinit the TapGestureRecognizer
    fileprivate func deinitGestureRecognizer () {
        self.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
    }
    
    
    /// called when touch any space inside the TapGestureRecognizer
    @objc fileprivate func tapGestureRecognizerAction() {
        let point = tapGestureRecognizer.location(in: self)
        removeHighlights(withType: .select)
        let ayah = selectedAyah(atPoint: point)
        let rect = ayah?.info?.rects.first?.applying(CGAffineTransform(scaleX: imageScale.width, y: imageScale.height)) ?? CGRect.zero
        QuranViewController.ayahOptions?.show(optionsForAyah: ayah, atLocation: self.convert(CGPoint(x: rect.midX, y: rect.minY), to: nil))
        QuranViewController.ayahOptions?.onMarkAyah = onMarkAyah(_:)
        highlight(ayah: ayah, withType: .select)
    }
}

//MARK: - Helpers
extension HighlightView {
    
    /// select the ayah at the given point
    ///
    /// - Parameter point: CGPoint that is representing any glyphs in this ayah
    /// - Returns: the selected ayah if exist
    func selectedAyah(atPoint point: CGPoint) -> Ayah? {
        for surah in page.getAllSurah() {
            for ayah in surah.allAyah {
                if ayah.info?.contain(point: point, withImageScale: imageScale) == true {
                    return ayah
                }
            }
        }
        
        return nil
    }
    
    
    func onMarkAyah(_ ayah: Ayah) {
        removeHighlights(withType: .select)
        
        if ayah.isBookmarked {
            highlight(ayah: ayah, withType: .bookmark)
        }else {
            removeHighlights(forAyah: ayah, withType: .bookmark)
        }
    }
    
    func onPlayAyah(_ ayah: Ayah) {
        removeHighlights(withType: .select)
        
        if ayah.isPlaying {
            highlight(ayah: ayah, withType: .reading)
        }else {
            removeHighlights(forAyah: ayah, withType: .reading)
        }
    }
    
    /// add missing highlights for current page
    func addMissingHighlightsForCurrentPage() {
        for surah in page.getAllSurah() {
            for ayah in surah.allAyah {
                if ayah.isBookmarked {
                    highlight(ayah: ayah, withType: .bookmark)
                }
                
                if ayah.isPlaying {
                    highlight(ayah: ayah, withType: .reading)
                }
            }
        }
    }
}

//MARK: - Highlights
extension HighlightView {
    
    /// draw the current highlights
    func drawHighlights() {
        self.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        
        for highlight in highlights {
            let lay = CALayer()
            lay.frame = highlight.rect.applying(CGAffineTransform(scaleX: imageScale.width, y: imageScale.height))
            lay.backgroundColor = highlight.type.color.cgColor
            self.layer.addSublayer(lay)
        }
    }
    
    
    /// reset all highlights
    func resetHighlights() {
        self.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.highlights.removeAll()
    }
    
    
    
    /// highlight the given ayah if exist
    ///
    /// - Parameters:
    ///   - ayah: Ayah object that contain the ayah data, it must contain the ayah info data
    ///   - type: the highlighting type
    func highlight(ayah: Ayah?, withType type: HighlightType) {
        guard let ayah = ayah, let info = ayah.info else {
            return
        }
        
        info.rects.forEach({ self.highlights.append(HighlightedRect(rect: $0, type: type, ayah: ayah)) })
        drawHighlights()
    }
    
    
    /// remove all highlights for the given type
    ///
    /// - Parameter type: the highlights type
    func removeHighlights(withType type: HighlightType) {
        for highlight in highlights {
            if highlight.type == type {
                let _ = highlights.index(where: { $0 == highlight }).map({ self.highlights.remove(at: $0) })
            }
        }
    }
    
    
    /// remove all highlights for the given ayah with the given type
    ///
    /// - Parameters:
    ///   - ayah: Ayah object that contain the ayah data
    ///   - type: the highlight type
    func removeHighlights(forAyah ayah: Ayah?, withType type: HighlightType) {
        guard let ayah = ayah else {
            return
        }
        
        for highlight in highlights {
            if highlight.type == type && ayah == highlight.ayah {
                let _ = highlights.index(where: { $0 == highlight }).map({ self.highlights.remove(at: $0) })
            }
        }
    }
}
