//
//  HomeContainerViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class HomeContainerViewController: SlideMenuController {

    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Home") {
            self.mainViewController = controller
        }
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SideMenu") {
            self.rightViewController = controller
        }
        
        SlideMenuOptions.hideStatusBar = false
        SlideMenuOptions.rightViewWidth = max(screenWidth * 0.6, 225.0)
        
        super.awakeFromNib()
    }

}
