//
//  BookmarksViewController.swift
//  Quran
//
//  Created by Eslam on 4/2/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var bookMarks: [BookMark] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "BookMarkTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        backgroundQueue {
            self.bookMarks = DBHelper.shared.getBookMarks()
            
            mainQueue {
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: - IBActions
    @IBAction func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - table view
extension BookmarksViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookMarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookMarkTableViewCell
        cell.initWith(bookMark: bookMarks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainQueue {
            QuranViewController.showQuran(startingFromPage: self.bookMarks[indexPath.row].ayah.page, fromController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "حذف", handler: { (_, path) in
            self.handleRowAction(atIndexPath: path)
        })]
    }
    
    func handleRowAction(atIndexPath indexPath: IndexPath) {
        DBHelper.shared.delete(bookMark: bookMarks[indexPath.row])
        bookMarks.remove(at: indexPath.row)
        tableView.reloadData()
    }
}
