//
//  AboutUsViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/15/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    //MARK: - IBActions
    @IBAction func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareAction() {
        share(items: [Config.APPSTORE_URL], forController: self, excludedActivityTypes: [.addToReadingList, .airDrop, .assignToContact, .saveToCameraRoll, .print])
    }
}
