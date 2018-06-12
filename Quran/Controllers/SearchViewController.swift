//
//  SearchViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 5/7/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import PromiseKit

class SearchViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var typeSegmentedControl: UISegmentedControl!
    
    
    var searchKeyword: String = "" {
        didSet {
            ayahPage = 1
            shouldLoadMoreAyah = true
            isSearchingForSurah ? searchForSurah() : searchForAyah()
        }
    }

    var isSearchingForSurah: Bool { get { return typeSegmentedControl.selectedSegmentIndex == 0 } }
    
    var surahResults: [Surah] = []
    var ayahResults: [SearchResult] = []
    
    
    var ayahPage: Int = 1
    var shouldLoadMoreAyah: Bool = true
    
    
    public static func search(forKeyword keyword: String, inSurah isSurah: Bool, fromController controller: UIViewController) {
        let screen = controller.storyboard?.instantiateViewController(withIdentifier: "SearchScreen") as! SearchViewController
        controller.present(screen, animated: true) {
            screen.searchKeyword = keyword
            screen.searchTextField.text = keyword
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        typeSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "GESSTextLight-Light", size: isIpadScreen ? 34 : 17)!], for: .normal)
    }

    //MARK: - IBActions
    @IBAction func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchAction() {
        searchTextField.resignFirstResponder()
        searchKeyword = searchTextField.text ?? ""
    }
    
    @IBAction func searchTextChangeAction() {
        if searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            searchKeyword = searchTextField.text!
        }
    }
    
    @IBAction func typeChangeAction() {
        searchKeyword = searchTextField.text!
    }
}

//MARK: - Helpers
extension SearchViewController {
    fileprivate func searchForSurah() {
        DispatchQueue.global(qos: .utility).async {
            self.surahResults = QuranManager.manager.AllSurah.filter({ return $0.name.contains(self.searchKeyword) })
            
            mainQueue {
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func searchForAyah() {
        print("searching for: \(searchKeyword)")
        DispatchQueue.global(qos: .utility).async {
            DBHelper.shared.searchForAyah(withText: self.searchKeyword, atPage: self.ayahPage).done { results -> Void in
                if self.ayahPage > 1 {
                    self.ayahResults += results
                }else {
                    self.ayahResults = results
                }
                
                if results.count == 0 {
                    self.shouldLoadMoreAyah = false
                }
                
                mainQueue {
                    self.tableView.reloadData()
                }
                
                }.catch { error in
                    displayAlert("عذرا حدث خطأ, برجاء المحاولة مرة اخرى لاحقا", forController: self)
            }
        }
    }
}

//MARK: - table view
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchingForSurah ? surahResults.count : ayahResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return isSearchingForSurah ? getSurahCell(atIndexPath: indexPath) : getAyahCell(atIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isSearchingForSurah {
            if indexPath.row == ayahResults.count - 1 && shouldLoadMoreAyah {
                ayahPage += 1
                searchForAyah()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPage = isSearchingForSurah ? surahResults[indexPath.row].page : ayahResults[indexPath.row].ayah.page
        
        mainQueue {
            QuranViewController.showQuran(startingFromPage: selectedPage, fromController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func getSurahCell(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurahCell", for: indexPath) as! SurahTableViewCell
        cell.initWith(sura: surahResults[indexPath.row])
        return cell
    }
    
    func getAyahCell(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AyahCell", for: indexPath) as! AyahTableViewCell
        cell.initWith(result: ayahResults[indexPath.row])
        return cell
    }
    
    func initTableView() {
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "SurahTableViewCell", bundle: nil), forCellReuseIdentifier: "SurahCell")
        tableView.register(UINib(nibName: "AyahTableViewCell", bundle: nil), forCellReuseIdentifier: "AyahCell")
    }
}
