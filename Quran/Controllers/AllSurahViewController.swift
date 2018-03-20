//
//  AllSurahViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/20/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class AllSurahViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    
    
    let allSurah = DBHelper.shared.getAllSurah()
    
    var surah: [Surah] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
    }

    
    
    
    //MARK: - IBActions
    @IBAction func menuAction() {
    }
    
    @IBAction func searchAction() {
    }
}

//MARK: - table view
extension AllSurahViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSurah.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurahTableViewCell
        cell.initWith(sura: allSurah[indexPath.row])
        return cell
    }
    
    
    /// init all surah table view for the first time
    func initTableView()  {
        tableView.register(UINib(nibName: "SurahTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
}
