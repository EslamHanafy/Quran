//
//  QuranHeaderView.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/11/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranHeaderView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var pageLabel: UILabel!
    @IBOutlet var surahLabel: UILabel!
    @IBOutlet var juzLabel: UILabel!
    @IBOutlet var menuView: UIView!
    
    fileprivate var parent: QuranViewController!
    
    fileprivate var page: Page!
    
    fileprivate var pageOptions: PageOptionsView!
    
    
    /// the show/hide animation duration
    fileprivate let animationDuration: TimeInterval = 0.8
    
    
    /// get new instance from QuranHeaderView
    ///
    /// - Parameter controller: The view controller that will be responsable for displaying this instance
    /// - Returns: new instance from QuranHeaderView
    public static func getInstance(forController controller: QuranViewController) -> QuranHeaderView {
        let view = Bundle.main.loadNibNamed("QuranHeaderView", owner: controller, options: nil)?.first as! QuranHeaderView
        controller.view.addSubview(view)
        
        view.parent = controller
        view.pageOptions = PageOptionsView.getInstance(forController: controller)
        view.initDesigns()
        return view
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if !containerView.frame.contains(touch.location(in: self)) {
                self.hide()
            }
        }
    }
    
    
    //MARK: - IBActions
    @IBAction func backAction() {
        parent.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuAction() {
        pageOptions.show(forPage: page)
    }
}

//MARK: - Helpers
extension QuranHeaderView {
    /// make necessary changes to the design
    fileprivate func initDesigns() {
        //add missing constraints
        addMissingConstrinats(withSuperView: parent.view)
        self.isHidden = true
    }
    
    /// add missing constraints between self and the given view
    ///
    /// - Parameter view: the super view for this instance
    private func addMissingConstrinats(withSuperView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        //leading
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        //trailing
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        //top
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        //bottom
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        view.layoutIfNeeded()
    }
    
    /// hide the popup view
    func hide() {
        hideAnimation()
    }
    
    
    /// show the popup view with given CartItem
    func show(forPage page: Page) {
        self.page = page
        
        updatePageData()
        showAnimation()
    }
    
    /// update current page data
    fileprivate func updatePageData() {
        self.pageLabel.text = String(page.id)
        self.surahLabel.text = page.getAllSurah().first?.name ?? ""
        self.juzLabel.text = page.juz.name
    }
}

//MARK: - Animation
extension QuranHeaderView {
    
    /// display the popup view with animation
    fileprivate func showAnimation() {
        containerView.center.y -= screenHeight
        
        UIView.transition(with: self, duration: animationDuration * 0.8 , options: [.transitionCrossDissolve], animations: {
            self.isHidden = false
        }, completion: nil)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.containerView.center.y += screenHeight
        }, completion: nil)
    }
    
    
    /// hide the popup view with animation
    fileprivate func hideAnimation(){
        UIView.animate(withDuration: animationDuration * 0.4, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = true
            self.alpha = 1.0
        }
    }
}
