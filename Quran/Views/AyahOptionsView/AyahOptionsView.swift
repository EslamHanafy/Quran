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
    @IBOutlet var bookmarkLabel: UILabel!
    @IBOutlet var playImageView: UIImageView!
    @IBOutlet var playLabel: UILabel!
    
    fileprivate var parent: UIViewController!
    fileprivate var ayah: Ayah!
    
    /// the show/hide animation duration
    fileprivate let animationDuration: TimeInterval = 0.8
    
    var onMarkAyah: ((_ ayah: Ayah)->())? = nil
    var onHideOptionsView: ((_ ayah: Ayah)->())? = nil
    
    
    
    /// get new instance from AyahOptionsView
    ///
    /// - Parameter controller: The view controller that will be responsable for displaying this instance
    /// - Returns: new instance from AyahOptionsView
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
    
    
    
    //MARK: - IBActions
    @IBAction func playAction() {
        if ayah.audioFiles.path(forMode: QuranManager.manager.audioMode) == nil {
            QuranManager.manager.showDownloadOptions(forAyah: ayah)
        }else {
            if ayah.isPlaying {
                QuranManager.manager.pauseCurrentAyah()
            }else {
                QuranManager.manager.play(ayah: ayah)
            }
            
            self.hide()
        }
    }
    
    @IBAction func markAction() {
        if ayah.isBookmarked {
            unBookmarkCurrentAyah()
        }else {
            bookmarkCurrentAyah()
        }
        
        hide()
    }
    
}

//MARK: - Helpers
extension AyahOptionsView {
    
    /// make necessary changes to the design
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
    
    
    
    /// show the popup view for the given ayah
    ///
    /// - Parameters:
    ///   - ayah: Ayah object that contain the ayah data
    ///   - point: ayah location in the screen
    func show(optionsForAyah ayah: Ayah, atLocation point: CGPoint) {
        self.ayah = ayah
        
        prepareActions()
        showAnimation(fromPoint: getValidPoint(fromPoint: point))
    }
    
    
    /// get valid point from the given point and ensure it will be inside the screen
    ///
    /// - Parameter point: the point that you want to validate
    /// - Returns: a valid CGPoint
    private func getValidPoint(fromPoint point: CGPoint) -> CGPoint {
        var point = point
        if point.x - (containerView.bounds.width / 2) < 0  {
            point.x = (containerView.bounds.width / 2) + 4
        }
        
        if point.x + (containerView.bounds.width / 2) > screenWidth {
            point.x = screenWidth - (containerView.bounds.width / 2) - 4
        }
        
        return point
    }
    
    /// change bookmarkLabel based on current ayah
    private func prepareActions() {
        bookmarkLabel.text = ayah.isBookmarked ? "حذف الفاصل" : "اضافة فاصل"
        playLabel.text = ayah.isPlaying ? "إيقاف" : "تشغيل"
        playImageView.image = UIImage(named: ayah.isPlaying ? "pause icon" : "play icon")
    }
    
    
    /// mark current ayah as bookmarked
    fileprivate func bookmarkCurrentAyah() {
        DBHelper.shared.addBookMark(forAyah: ayah)
        ayah.isBookmarked = true
        onMarkAyah?(ayah)
        displayAlertWithTimer("تم اضافة الفاصل بنجاح", forController: self.parent, timeInSeconds: 3.0)
    }
    
    
    /// mark current ayah as not bookmarked
    fileprivate func unBookmarkCurrentAyah() {
        DBHelper.shared.delete(bookmarkForAyah: ayah)
        ayah.isBookmarked = false
        onMarkAyah?(ayah)
        displayAlertWithTimer("تم حذف الفاصل بنجاح", forController: self.parent, timeInSeconds: 3.0)
    }
}

//MARK: - Animation
extension AyahOptionsView {
    
    /// display the popup view with animation
    fileprivate func showAnimation(fromPoint point: CGPoint) {
        containerView.center = point
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
            self.onHideOptionsView?(self.ayah)
        }
    }
}
