//
//  QuranPageCollectionViewCell.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/24/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranPageCollectionViewCell: UICollectionViewCell {

    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var highlightView: HighlightView!
    
    var page: Page!
    
 
    /// init cell for the first time
    ///
    /// - Parameter page: Page object that contain the page data
    func initWith(page: Page) {
        self.page = page
        page.updateData()
        mainImageView.image = UIImage(named: "page" + String(format: "%03d", page.id))
        highlightView.initWith(imageView: mainImageView)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        highlightView.reset()
    }
}
