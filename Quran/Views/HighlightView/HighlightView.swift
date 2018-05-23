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
    fileprivate var imageScale: (width: CGFloat, height: CGFloat) {
        get {
            let size = mainImageView.aspectFitSize
            return ((size.width / 1280.0), (size.height / 2071))
        }
    }
    
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    func initWith(imageView: UIImageView) {
        self.mainImageView = imageView
        initGestureRecognizer()
    }
    
    func reset() {
        deinitGestureRecognizer()
    }
}

//MARK - GestureRecognizer
extension HighlightView {
    fileprivate func initGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizerAction))
    }
    
    fileprivate func deinitGestureRecognizer () {
        self.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
    }
    
    @objc fileprivate func tapGestureRecognizerAction() {
        
    }
}
