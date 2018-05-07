//
//  AyahTableViewCell.swift
//  Quran
//
//  Created by Eslam Hanafy on 5/7/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit


class AyahTableViewCell: UITableViewCell {

    @IBOutlet var ayahLabel: UILabel!
    @IBOutlet var ayahNumberLabel: UILabel!
    @IBOutlet var surahLabel: UILabel!
    
    
    /// init cell for the first time
    ///
    /// - Parameter result: SearchResult object that contain the result data
    func initWith(result: SearchResult) {
        ayahLabel.text = result.ayah.content
        surahLabel.text = "سورة " + result.surah.name
        ayahNumberLabel.text = "آية رقم " + String(result.ayah.id)
    }
}
