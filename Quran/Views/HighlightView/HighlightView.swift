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
    
    
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !highlights.isEmpty else { return }
        
        let context = UIGraphicsGetCurrentContext()
        
        for highlight in highlights {
            context?.setFillColor(highlight.type.color.cgColor)
            context?.fill(highlight.rect.applying(CGAffineTransform(scaleX: imageScale.width, y: imageScale.height)))
        }
    }
    

    
    func initWith(imageView: UIImageView, forPage page: Page) {
        self.mainImageView = imageView
        initGestureRecognizer()
        self.page = page
    }
    
    func reset() {
        deinitGestureRecognizer()
    }
}

//MARK - GestureRecognizer
extension HighlightView {
    fileprivate func initGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizerAction))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func deinitGestureRecognizer () {
        self.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
    }
    
    @objc fileprivate func tapGestureRecognizerAction() {
        let point = tapGestureRecognizer.location(in: self)
        if let ayah = selectedAyah(atPoint: point) {
            print("selected ayah: \(ayah.content)")
            highlights.removeAll()
            ayah.info?.rects.forEach({ self.highlights.append(HighlightedRect(rect: $0, type: .select)) })
            setNeedsDisplay()
        }else{
            print("couldn't determine the selected ayah")
        }
    }
}

//MARK: - Helpers
extension HighlightView {
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
}
