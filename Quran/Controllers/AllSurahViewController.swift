//
//  AllSurahViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/20/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class AllSurahViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    
    
    override func viewDidLoad() { 
        super.viewDidLoad()

        tableView.register(UINib(nibName: "SurahTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }

    
    //MARK: - IBActions
    @IBAction func menuAction() {
        self.openRight()
    }
    
    @IBAction func searchAction() {
        searchTextField.resignFirstResponder()
        
        if searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            SearchViewController.search(forKeyword: searchTextField.text!, inSurah: true, fromController: self)
        }
    }
}

//MARK: - table view
extension AllSurahViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuranManager.manager.AllSurah.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurahTableViewCell
        cell.initWith(sura: QuranManager.manager.AllSurah[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSurah = QuranManager.manager.AllSurah[indexPath.row]
        
        mainQueue {
            QuranViewController.showQuran(startingFromPage: selectedSurah.page, fromController: self)
        }
    }
}
