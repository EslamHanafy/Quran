//
//  JuzTableViewCell.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class JuzTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var surahLabel: UILabel!
    
    
    /// init cell for the first time
    ///
    /// - Parameter juz: Juz object that contain the juz data
    func initWith(juz: Juz) {
        nameLabel.text = juz.name
        surahLabel.text = juz.surah.name
    }
}
