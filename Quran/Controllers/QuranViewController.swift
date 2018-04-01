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
    
    var pages: [Page] = []
    
    var currentPageNumber: Int = 0
    
    public static weak var ayahOptions: AyahOptionsView? = nil
    
    
    public static func showQuran(startingFromPage page: Int64, fromController controller: UIViewController) {
        let quran = controller.storyboard!.instantiateViewController(withIdentifier: "QuranScreen") as! QuranViewController
        quran.currentPageNumber = Int(page)
        controller.present(quran, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pages = DBHelper.shared.getAllPages()
        initCollectionView()
//        QuranViewController.ayahOptions = AyahOptionsView.getInstance(forController: self)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if currentPageNumber > 0 {
            collectionView.scrollToItem(at: IndexPath(item: currentPageNumber - 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
    }
    
    
    
    //MARK: - IBAction
    @IBAction func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Collection View
extension QuranViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! QuranPageCollectionViewCell
        cell.initWith(page: pages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: screenHeight * 0.8898)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func initCollectionView() {
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.minimumLineSpacing = 0
        collectionView.register(UINib(nibName: "QuranPageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
}
