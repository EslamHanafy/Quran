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
    
    var currentPageNumber: Int = 0
    
    var shouldUpdateTextView: Bool = false
    
    public static weak var ayahOptions: AyahOptionsView? = nil
    
    
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
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToCurrentPageIfNeeded()
    }
    
    
    //MARK: - IBAction
    @IBAction func showBarAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Helpers
extension QuranViewController {
    
    func scrollToCurrentPageIfNeeded() {
        if currentPageNumber > 0 {
            collectionView.scrollToItem(at: IndexPath(item: currentPageNumber - 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
        
        updateTextView()
    }
    
    func updateTextView() {
        let indexPath = IndexPath(item: currentPageNumber - 1, section: 0)
        
        guard let textView = (collectionView.cellForItem(at: indexPath) as? QuranPageCollectionViewCell)?.quranTextView else {
            return print("could n't get the text view eslam")
        }
        print("text view updated eslam")
        QuranManager.manager.currentTextView = textView
        shouldUpdateTextView = true
    }
    
    func scrollToNextPage() {
        if currentPageNumber < 604 {
            currentPageNumber += 1
            
            let indexPath = IndexPath(item: currentPageNumber - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    func scrollToPreviousPage() {
        if currentPageNumber > 0 {
            currentPageNumber -= 1
            
            let indexPath = IndexPath(item: currentPageNumber - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
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
        return CGSize(width: screenWidth * 0.9, height: screenHeight * 0.8898)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        var page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        page = Int(abs(Int32(page - 603)))
        currentPageNumber = page + 1
        updateTextView()
        print("will display cell at index: \(currentPageNumber)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateTextView()
    }
    
    func initCollectionView() {
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.minimumLineSpacing = 0
        collectionView.register(UINib(nibName: "QuranPageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
}
