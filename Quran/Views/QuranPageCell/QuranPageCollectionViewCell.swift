//
//  QuranPageCollectionViewCell.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/24/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranPageCollectionViewCell: UICollectionViewCell {

    @IBOutlet var surahLabel: UILabel!
    @IBOutlet var juzLabel: UILabel!
    @IBOutlet var quranTextView: QuranTextView!
    @IBOutlet var pageLabel: UILabel!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    
    var page: Page!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        quranTextView.preapareForReuse()
    }
    
 
    /// init cell for the first time
    ///
    /// - Parameter page: Page object that contain the page data
    func initWith(page: Page) {
        self.page = page
        
        surahLabel.text = page.allSurah.first?.name ?? ""
        juzLabel.text = page.juz.name
        pageLabel.text = String(page.id)
        quranTextView.initWith(page: page)
    }
    
}
