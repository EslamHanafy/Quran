//
//  QuranViewController.swift
//  Quran
//
//  Created by Eslam on 3/22/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var collectionLayout: UICollectionViewFlowLayout!
    @IBOutlet var containerView: UIView!
    @IBOutlet var menuView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    /// determine which page is currently displaying and what page should be displayed at the beginning
    var currentPageNumber: Int = 0 {
        didSet { self.titleLabel?.text = QuranManager.manager.pages[currentPageNumber - 1].allSurah.first?.name }
    }
    
    var shouldScrollToCurrentPage: Bool = true
    
    /// determine if should play the menu icon animation
    var shouldAnimateMenuView: Bool = true
    
    fileprivate var pageOptions: PageOptionsView!
    
    /// AyahOptionsView for every ayah
    public static weak var ayahOptions: AyahOptionsView? = nil
    
    
    
    /// show the quran screen at the given page
    ///
    /// - Parameters:
    ///   - page: the screen start page
    ///   - controller: the view controller that will be responsable for displaying this controller
    public static func showQuran(startingFromPage page: Int64, fromController controller: UIViewController) {
        let quran = controller.storyboard!.instantiateViewController(withIdentifier: "QuranScreen") as! QuranViewController
        quran.currentPageNumber = Int(page)
        controller.present(quran, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCollectionView()
        QuranViewController.ayahOptions = AyahOptionsView.getInstance(forController: self)
        QuranManager.manager.currentQuranController = self
        pageOptions = PageOptionsView.getInstance(forController: self)
        reloadTheme()
        self.titleLabel.text = QuranManager.manager.pages[currentPageNumber - 1].getAllSurah().first?.name
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToCurrentPageIfNeeded()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        if shouldScrollToCurrentPage {
            collectionView.reloadData()
        }
        
        shouldScrollToCurrentPage = false
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionLayout.invalidateLayout()
    }
    
    //MARK: - IBActions
    @IBAction func optionsAction() {
        pageOptions.show(forPage: QuranManager.manager.pages[currentPageNumber - 1])
    }
    
    @IBAction func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Helpers
extension QuranViewController {
    
    /// scroll to currentPageNumber
    func scrollToCurrentPageIfNeeded() {
        if currentPageNumber > 0 && shouldScrollToCurrentPage {
            collectionView.scrollToItem(at: IndexPath(item: currentPageNumber - 1, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
            collectionView.reloadData()
        }
    }
    
    
    /// scroll to next page in the quran
    func scrollToNextPage() {
        if currentPageNumber < 604 {
            currentPageNumber += 1
            
            scroll(toPage: currentPageNumber)
        }
    }
    
    
    /// scroll to previous page in the quran
    func scrollToPreviousPage() {
        if currentPageNumber > 1 {
            currentPageNumber -= 1
            
            scroll(toPage: currentPageNumber)
        }
    }
    
    
    /// scroll to the given page
    ///
    /// - Parameter page: the page number starting from 1
    func scroll(toPage page: Int) {
        guard page <= 604 && page > 0 else {
            return
        }
        
        currentPageNumber = page
        let indexPath = IndexPath(item: currentPageNumber - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    /// reload the screen design based on current theme
    func reloadTheme() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.backgroundColor = QuranManager.manager.isNightMode ? .black : hexStringToUIColor(hex: "F6EEDF")
            self.collectionView.reloadData()
            self.updateHeaderDesign()
            QuranViewController.ayahOptions?.updateDesign()
        }
        
        UIApplication.shared.keyWindow?.tintColor = QuranManager.manager.isNightMode ? .black : UIColor(red: 104/255.0, green: 166/255.0, blue: 89/255.0, alpha: 1.0)
    }
    
    /// update header design colors based on current theme
    func updateHeaderDesign() {
        let color: UIColor = QuranManager.manager.isNightMode ? UIColor(red: 194/255.0, green: 194/255.0, blue: 194/255.0, alpha: 1.0) : UIColor(red: 104/255.0, green: 166/255.0, blue: 89/255.0, alpha: 1.0)
        
        headerView.backgroundColor = color
        pageOptions.updateDesign()
    }
}

//MARK: - Collection View
extension QuranViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return QuranManager.manager.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! QuranPageCollectionViewCell).initWith(page: QuranManager.manager.pages[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        currentPageNumber = 603 - page + 1
        print("will display cell at index: \(currentPageNumber)")
    }

    /// init the collection view for the first time
    func initCollectionView() {
        collectionView.register(UINib(nibName: "QuranPageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
}
