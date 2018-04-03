//
//  JuzViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class JuzViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    
    
    var filtered: [Juz] = []
    
    var searchKeyword: String = "" {
        didSet {
            filtered = QuranManager.manager.allJuz.filter({ return $0.name.contains(searchKeyword) || $0.surah.name.contains(searchKeyword) })
            tableView.reloadData()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "JuzTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    
    
    //MARK: - IBActions
    @IBAction func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchAction() {
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func searchTextChangeAction() {
        searchKeyword = searchTextField.text ?? ""
    }
}

//MARK: - table view
extension JuzViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchKeyword.isEmpty ? QuranManager.manager.allJuz.count : filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! JuzTableViewCell
        cell.initWith(juz: searchKeyword.isEmpty ? QuranManager.manager.allJuz[indexPath.row] : filtered[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedJuz = searchKeyword.isEmpty ? QuranManager.manager.allJuz[indexPath.row] : filtered[indexPath.row]
        
        mainQueue {
            QuranViewController.showQuran(startingFromPage: selectedJuz.ayah.page, fromController: self)
        }
    }
}

