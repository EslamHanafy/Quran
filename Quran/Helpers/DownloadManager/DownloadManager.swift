//
//  DownloadManager.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/8/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
    public static let shared: DownloadManager = DownloadManager()
    
    
    /// the download manager
    fileprivate lazy var manager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.magdsoft.Quran.BackgroundSession"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    
    
    /// current audio mode for the downloaded files
    fileprivate var currentMode: AudioMode!
    
    /// a queue that contain all ayah that should be downloaded
    fileprivate var downloadQueue: [Ayah] = []
    
    /// current view controller in the controllers hierarchy
    fileprivate var currentViewController: UIViewController {
        get {
            return getCurrentViewController() ?? UIViewController()
        }
    }
    
    /// the download popup view
    fileprivate let downloadView: DownloadView = DownloadView.getInstance(forController: getCurrentViewController() ?? UIViewController())
    
    /// the download path
    fileprivate let downloadPath: String = MZUtility.baseFilePath + "/QuranDownloads"
    
    
    
    override init() {
        super.init()
        
        downloadView.onShouldPause = self.downloadViewOnShouldPauseDownloading
        downloadView.onShouldCancel = self.downloadViewOnShouldCancelDownloading
        downloadView.onShouldResume = self.downloadViewOnShouldResumeDownloading
    }
    
    
    /// download all audio files for the given page and audio mode
    ///
    /// - Parameters:
    ///   - page: the page that you want to download it's files
    ///   - mode: the audio mode for downloaded files
    func download(page: Page, forMode mode: AudioMode = .normal) {
        self.currentMode = mode
        
        for surah in page.getAllSurah() {
            for ayah in surah.allAyah {
                if ayah.audioFiles?.path(forMode: currentMode) == nil {
                    downloadQueue.append(ayah)
                }
            }
        }
        
        if MZUtility.getFreeDiskspace().migaBytes < Double(downloadQueue.count * 4) {
            displayAlert("عذرا لا توجد مساحة كافية متوفرة, يجب ان يتوفر \(downloadQueue.count * 4) ميجا", forController: currentViewController)
            downloadQueue.removeAll()
        }else {
            if let ayah = downloadQueue.first {
                download(ayah: ayah)
            }
        }
    }
    
    
    
    /// download an audio file for the given ayah and audio mode from server
    ///
    /// - Parameters:
    ///   - ayah: the ayah that you want to download it's file
    ///   - mode: the audio mode for the downloaded file
    func download(ayah: Ayah, forMode mode: AudioMode) {
        self.currentMode = mode
        
        if MZUtility.getFreeDiskspace().migaBytes < 4.0 {
            displayAlert("عذرا لا توجد مساحة كافية متوفرة, يجب ان يتوفر \(4) ميجا", forController: currentViewController)
        }else {
            downloadQueue.append(ayah)
            download(ayah: ayah)
        }
    }
    
    
    /// add download task for the given ayah
    ///
    /// - Parameter ayah: the ayah that you want to download it
    fileprivate func download(ayah: Ayah) {
        var fileName = "\(ayah.surah.id)/\(ayah.id).mp3"
        let url = Config.baseURL(forMode: currentMode) + fileName
        fileName = MZUtility.getUniqueFileNameWithPath(fileName as NSString) as String
        manager.addDownloadTask(fileName, fileURL: url, destinationPath: downloadPath, ayah: ayah)
    }
}

//MARK: - MZDownloadManager delegate
extension DownloadManager: MZDownloadManagerDelegate {
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        downloadView.update(DownloadModel: downloadModel)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel]) {
        
    }
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        mainQueue {
            self.downloadView.show(downloadModel: downloadModel)
        }
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        downloadQueue.remove(at: 0)
        downloadModel.ayah?.update(audioPath: downloadModel.destinationPath, forMode: currentMode)
        
        if downloadQueue.isEmpty {
            mainQueue {
                self.downloadView.hide()
            }
        }else {
            download(ayah: downloadQueue[0], forMode: currentMode)
        }
    }
    
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        print("the download error is: \(error)")
        mainQueue {
            displayAlertWithTimer("حدث خطأ اثناء تنزيل الاية رقم \(downloadModel.ayah?.id ?? 0) من سورة \(downloadModel.ayah?.surah.name ?? "")", forController: self.currentViewController, timeInSeconds: 2.0)
        }
    }
}

//MARK: - DownloadView
extension DownloadManager {
    
    fileprivate func downloadViewOnShouldCancelDownloading() {
        for (index, _) in manager.downloadingArray.enumerated() {
            manager.cancelTaskAtIndex(index)
        }
        
        downloadView.hide()
    }
    
    fileprivate func downloadViewOnShouldPauseDownloading() {
        for (index, _) in manager.downloadingArray.enumerated() {
            manager.pauseDownloadTaskAtIndex(index)
        }
    }
    
    fileprivate func downloadViewOnShouldResumeDownloading() {
        for (index, _) in manager.downloadingArray.enumerated() {
            manager.resumeDownloadTaskAtIndex(index)
        }
    }
}

