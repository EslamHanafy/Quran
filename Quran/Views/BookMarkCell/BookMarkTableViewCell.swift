//
//  BookMarkTableViewCell.swift
//  Quran
//
//  Created by Eslam on 4/2/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class BookMarkTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var pageLabel: UILabel!
    
    
    /// init cell for the first time
    ///
    /// - Parameter bookMark: BookMark object that contain the bookmark data
    func initWith(bookMark: Bookmark) {
        nameLabel.text = bookMark.surah.name
        pageLabel.text = "صفحة رقم " + getValidatedNumber(fromInt: Int(bookMark.ayah.page))
    }
}
