//
//  SideMenuTableViewCell.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit


class SideMenuTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    
    /// init cell for the first time
    ///
    /// - Parameter item: MenuItem object that contain the menu data
    func initWith(item: MenuItem) {
        titleLabel.text = item.title
        iconImageView.image = UIImage(named: item.icon)
    }
}
