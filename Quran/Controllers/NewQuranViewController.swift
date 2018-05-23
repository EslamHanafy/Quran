//
//  NewQuranViewController.swift
//  Quran
//
//  Created by Eslam on 5/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class NewQuranViewController: UIViewController {

    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
    var page: Page!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        page = QuranManager.manager.pages[0]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
//        for surah in page.allSurah {
//            for ayah in surah.allAyah {
//                let point = sender.location(in: mainImageView)
//                if ayah.contain(point: point) {
//                    ayah.glyphs.forEach({ self.addLayer(withRect: $0.rect) })
////                    self.addLayer(withRect: ayah.unionRect())
//                    return print("the selected ayah is: \(ayah.id) in surah: \(surah.name)")
//                }
//            }
//        }
    }
    

    func addLayer(withRect rect:CGRect) {
        let layer = CALayer()
        layer.frame = rect
        layer.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.5).cgColor
        containerView.layer.addSublayer(layer)
    }
}
