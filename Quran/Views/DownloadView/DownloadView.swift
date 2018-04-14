//
//  DownloadView.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/8/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class DownloadView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var surahLabel: UILabel!
    @IBOutlet var ayahLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var pauseButton: UIButton!
    
    
    fileprivate var parent: UIViewController!
    fileprivate var download: MZDownloadModel!
    
    /// the show/hide animation duration
    fileprivate let animationDuration: TimeInterval = 0.8
    
    
    var onShouldCancel: (()->())? = nil
    var onShouldPause: (()->())? = nil
    var onShouldResume: (()->())? = nil
    
    var isPaused: Bool = false
    
    
    
    
    /// get new instance form DownloadView
    ///
    /// - Parameter controller: The view controller that will be responsable for displaying this instance
    /// - Returns: new instance form DownloadView
    public static func getInstance(forController controller: UIViewController) -> DownloadView {
        let view = Bundle.main.loadNibNamed("DownloadView", owner: controller, options: nil)?.first as! DownloadView
        controller.view.addSubview(view)
        
        view.parent = controller
        view.initDesigns()
        return view
    }
    
    
    //MARK: - IBActions
    @IBAction func pauseAction() {
        if isPaused {
            onShouldResume?()
            isPaused = false
            pauseButton.setTitle("إيقاف", for: .normal)
        }else {
            onShouldPause?()
            isPaused = true
            pauseButton.setTitle("إستئناف", for: .normal)
        }
    }
    
    @IBAction func cancelAction() {
        displayCancelConfirmation()
    }
}

//MARK: - Helpers
extension DownloadView {
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
        isPaused = false
    }
    
    
    /// show the popup view with given CartItem
    func show(downloadModel download: MZDownloadModel) {
        self.download = download
        isPaused = false
        
        mainQueue {
            self.updateViews()
        }
        
        if self.isHidden {
            showAnimation()
        }
    }
    
    
    /// update current download model
    ///
    /// - Parameter download: MZDownloadModel object that contain the download data
    func update(DownloadModel download: MZDownloadModel) {
        self.download = download
        
        mainQueue {
            self.updateViews()
        }
    }
    
    
    /// update the displaying data based on current download model
    private func updateViews() {
        if let ayah = download.ayah {
            self.surahLabel.text = ayah.surah.name
            self.ayahLabel.text = "ابة رقم : \(ayah.id)"
            self.speedLabel.text = "سرعة التنزيل : \(download.speed?.speed ?? 0) \(download.speed?.unit ?? "")"
            self.sizeLabel.text = "حجم الملف : \(download.file?.size ?? 0) \(download.file?.unit ?? "")"
            
            if download.remainingTime?.hours ?? 0 > 0 {
                self.timeLabel.text = "الوقت المتبقى : \(download.remainingTime?.hours ?? 0) ساعة"
            }else if download.remainingTime?.minutes ?? 0 > 0 {
                self.timeLabel.text = "الوقت المتبقى : \(download.remainingTime?.minutes ?? 0) دقيقة"
            }else {
                self.timeLabel.text = "الوقت المتبقى : \(download.remainingTime?.seconds ?? 0) ثانية"
            }
            
            self.progressView.progress = download.progress
        }
    }
    
    /// display the confirmation alert to confirm that the user is really want to cancel the download
    fileprivate func displayCancelConfirmation() {
        let alert = UIAlertController(title: "الغاء التنزيل", message: "هل انت متأكد انك تريد الغاء تنزيل الايات", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "نعم", style: .destructive, handler: { (_) in
            self.onShouldCancel?()
        }))
        
        alert.addAction(UIAlertAction(title: "لا", style: .cancel, handler: nil))
        
        getCurrentViewController()?.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Animation
extension DownloadView {
    
    /// display the popup view with animation
    fileprivate func showAnimation() {
        self.containerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        UIView.transition(with: self, duration: animationDuration * 0.8 , options: [.transitionCrossDissolve], animations: {
            self.isHidden = false
        }, completion: nil)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.containerView.transform = CGAffineTransform.identity
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
