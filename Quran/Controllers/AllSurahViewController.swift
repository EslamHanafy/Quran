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
    
    
    var filtered: [Surah] = []
    
    
    var searchKeyword: String = "" {
        didSet {
            filtered = QuranManager.manager.AllSurah.filter({ return $0.name.contains(searchKeyword) })
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() { 
        super.viewDidLoad()

        tableView.register(UINib(nibName: "SurahTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
//        let results = DBHelper.shared.searchForAyah(withText: "سَيَقُولُ الَّذِينَ أَشْرَكُوا")
//        print(results)
    }

    
    
    
    //MARK: - IBActions
    @IBAction func menuAction() {
        self.openRight()
    }
    
    @IBAction func searchAction() {
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func searchTextChangeAction() {
        searchKeyword = searchTextField.text ?? ""
    }
}

//MARK: - table view
extension AllSurahViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchKeyword.isEmpty ? QuranManager.manager.AllSurah.count : filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurahTableViewCell
        cell.initWith(sura: searchKeyword.isEmpty ? QuranManager.manager.AllSurah[indexPath.row] : filtered[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSurah = searchKeyword.isEmpty ? QuranManager.manager.AllSurah[indexPath.row] : filtered[indexPath.row]
        
        mainQueue {
            QuranViewController.showQuran(startingFromPage: selectedSurah.page, fromController: self)
        }
    }
}
