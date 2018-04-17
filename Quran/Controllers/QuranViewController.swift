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
    @IBOutlet var collectionLayout: UICollectionViewFlowLayout!
    @IBOutlet var menuView: UIView!
    @IBOutlet var menuImageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    /// determine which page is currently displaying and what page should be displayed at the beginning
    var currentPageNumber: Int = 0
    
    var shouldScrollToCurrentPage: Bool = true
    
    /// determine if should play the menu icon animation
    var shouldAnimateMenuView: Bool = true
    
    
    /// The screen header view
    public static var header: QuranHeaderView!
    
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
        QuranViewController.header = QuranHeaderView.getInstance(forController: self)
        QuranManager.manager.currentQuranController = self
        reloadTheme()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToCurrentPageIfNeeded()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateMenuButtonIfNeeded()
        
        if shouldScrollToCurrentPage {
            collectionView.reloadData()
        }
        
        shouldScrollToCurrentPage = false
        updateTextView()
    }
    
    
    //MARK: - IBAction
    @IBAction func showBarAction() {
        QuranViewController.header.show(forPage: QuranManager.manager.pages[currentPageNumber - 1])
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
        
        updateTextView()
    }
    
    /// update current textview in QuranManager with the textview that is currently displaying in the screen
    func updateTextView() {
        let indexPath = IndexPath(item: currentPageNumber - 1, section: 0)
        
        guard let textView = (collectionView.cellForItem(at: indexPath) as? QuranPageCollectionViewCell)?.quranTextView else {
            return print("could n't get the text view eslam")
        }
        print("text view updated eslam")
        QuranManager.manager.currentTextView = textView
    }
    
    
    /// scroll to next page in the quran
    func scrollToNextPage() {
        if currentPageNumber < 604 {
            currentPageNumber += 1
            
            let indexPath = IndexPath(item: currentPageNumber - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    
    /// scroll to previous page in the quran
    func scrollToPreviousPage() {
        if currentPageNumber > 1 {
            currentPageNumber -= 1
            
            let indexPath = IndexPath(item: currentPageNumber - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }
    
    
    /// animte the menu icon if the shouldAnimateMenuView is true
    func animateMenuButtonIfNeeded() {
        if shouldAnimateMenuView {
            let animationDuration: Double = 0.6
            UIView.transition(with: menuImageView, duration: animationDuration, options: [.transitionCrossDissolve], animations: {
                self.menuImageView.image = UIImage(named: "drop down")
            }, completion: { (_) in
                UIView.transition(with: self.menuImageView, duration: animationDuration, options: [.transitionCrossDissolve], animations: {
                    self.menuImageView.image = UIImage(named: QuranManager.manager.isNightMode ? "downNight" : "drop down2")
                }, completion: nil)
            })
            
            UIView.animate(withDuration: animationDuration, animations: {
                self.menuView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { (_) in
                UIView.animate(withDuration: animationDuration, animations: {
                    self.menuView.transform = CGAffineTransform.identity
                })
            })
            
            shouldAnimateMenuView = false
        }
    }
    
    
    /// reload the screen design based on current theme
    func reloadTheme() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundImageView.image = UIImage(named: QuranManager.manager.isNightMode ? "nightFrame" : "frame")
            self.menuImageView.image = UIImage(named: QuranManager.manager.isNightMode ? "downNight" : "drop down2")
            self.collectionView.reloadData()
            QuranViewController.header.updateDesign()
            QuranViewController.ayahOptions?.updateDesign()
        }
        
        UIApplication.shared.keyWindow?.tintColor = QuranManager.manager.isNightMode ? .black : UIColor(red: 104/255.0, green: 166/255.0, blue: 89/255.0, alpha: 1.0)
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
        updateTextView()
        print("will display cell at index: \(currentPageNumber)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateTextView()
    }
    
    
    /// init the collection view for the first time
    func initCollectionView() {
        collectionView.register(UINib(nibName: "QuranPageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
}
