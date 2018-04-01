//
//  AyahOptionsView.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/31/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class AyahOptionsView: UIView {

    @IBOutlet var containerView: UIView!
    
    
    fileprivate var parent: UIViewController!
    fileprivate var ayah: Ayah!
    
    /// the show/hide animation duration
    fileprivate let animationDuration: TimeInterval = 0.8
    
    
    public static func getInstance(forController controller: UIViewController) -> AyahOptionsView {
        let view = Bundle.main.loadNibNamed("AyahOptionsView", owner: controller, options: nil)?.first as! AyahOptionsView
        controller.view.addSubview(view)
        
        view.parent = controller
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
    
    @IBAction func playAction() {
    }
    
    @IBAction func markAction() {
        DBHelper.shared.addBookMark(forAyah: ayah)
        hide()
        displayAlertWithTimer("تم اضافة الفاصل بنجاح", forController: self.parent, timeInSeconds: 3.0)
    }
    
}

//MARK: - Helpers
extension AyahOptionsView {
    fileprivate func initDesigns() {
        //add missing constraints
        addMissingConstrinats(withSuperView: parent.view)
        containerView.addPikeOnView(side: .Bottom)
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
    func show(optionsForAyah ayah: Ayah, atLocation point: CGPoint) {
        self.ayah = ayah
        
        var point = point
        if point.x - (containerView.bounds.width / 2) < 0  {
            point.x = (containerView.bounds.width / 2) + 4
        }
        
        if point.x + (containerView.bounds.width / 2) > screenWidth {
            point.x = screenWidth - (containerView.bounds.width / 2) - 4
        }
        
        showAnimation(fromPoint: point)
    }
}

//MARK: - Animation
extension AyahOptionsView {
    
    /// display the popup view with animation
    fileprivate func showAnimation(fromPoint point: CGPoint) {
        containerView.center = point
        containerView.center.y -= screenHeight
        
        UIView.transition(with: self, duration: animationDuration * 0.8 , options: [.showHideTransitionViews], animations: {
            self.isHidden = false
        }, completion: nil)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.containerView.center.y += screenHeight
        }, completion: nil)
    }
    
    
    /// hide the popup view with animation
    fileprivate func hideAnimation(){
        UIView.animate(withDuration: animationDuration * 0.5, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = true
            self.alpha = 1.0
        }
    }
}
