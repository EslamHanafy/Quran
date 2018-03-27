//
//  SuraTableViewCell.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/20/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class SurahTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    
    
    /// init cell for the first time
    ///
    /// - Parameter sura: Sura object that contain the sura data
    func initWith(sura: Surah) {
        titleLabel.text = sura.name
        numberLabel.text = String(sura.page)
    }
}
