//
//  DownloadManager.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/8/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import Toast_Swift

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
    
    /// the estimated file size for each ayah in MB
    fileprivate let estimatedFileSize: Double = 350.0 / 1024.0
    
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
    func download(page: Page, forMode mode: AudioMode) {
        self.currentMode = mode
        
        for surah in page.getAllSurah() {
            for ayah in surah.allAyah {
                if ayah.audioFiles.path(forMode: currentMode) == nil {
                    downloadQueue.append(ayah)
                }
            }
        }
        
        startDownloadingIfNeeded()
    }
    
    
    
    /// download an audio file for the given ayah and audio mode from server
    ///
    /// - Parameters:
    ///   - ayah: the ayah that you want to download it's file
    ///   - mode: the audio mode for the downloaded file
    func download(ayah: Ayah, forMode mode: AudioMode) {
        self.currentMode = mode
        
        if MZUtility.getFreeDiskspace().migaBytes < estimatedFileSize {
            displayAlert("عذرا لا توجد مساحة كافية متوفرة, يجب ان يتوفر \(estimatedFileSize) ميجا على الاقل", forController: currentViewController)
        }else {
            downloadQueue.append(ayah)
            download(ayah: ayah)
        }
    }
    
    
    /// download whole ayah for the given surah
    ///
    /// - Parameter surah: teh surah that you want to download
    func download(surah: Surah, forMode mode: AudioMode) {
        self.currentMode = mode
        
        let allAyah = DBHelper.shared.getAllAyah(forSurah: surah)
        
        for ayah in allAyah {
            downloadQueue.append(ayah)
        }
        
        startDownloadingIfNeeded()
    }
    
    func downloadQuran(forMode mode: AudioMode) {
        self.currentMode = mode
        
        let allAyah = DBHelper.shared.getAllAyah()
        
        for ayah in allAyah {
            downloadQueue.append(ayah)
        }
        
        startDownloadingIfNeeded()
    }
}

//MARK: - MZDownloadManager
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
        downloadModel.ayah?.update(audioPath: downloadModel.destinationPath + "/" + downloadModel.fileName, forMode: currentMode)
        
        if downloadQueue.isEmpty {
            mainQueue {
                self.downloadView.hide()
            }
        }else {
            download(ayah: downloadQueue[0])
        }
    }
    
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        print("the download error is: \(error)")
        mainQueue {
            self.currentViewController.view.makeToast("حدث خطأ اثناء تنزيل الاية رقم \(downloadModel.ayah?.id ?? 0) من سورة \(downloadModel.ayah?.surah.name ?? "")")
        }
    }
    
    
    /// start downloading the ayah in download queue
    fileprivate func startDownloadingIfNeeded() {
        if MZUtility.getFreeDiskspace().migaBytes < Double(downloadQueue.count) * estimatedFileSize {
            displayAlert("عذرا لا توجد مساحة كافية متوفرة, يجب ان يتوفر \(Double(downloadQueue.count) * estimatedFileSize) ميجا على الاقل", forController: currentViewController)
            cancellOldTasksIfNeeded()
        }else {
            if let ayah = downloadQueue.first {
                download(ayah: ayah)
            }
        }
    }
    
    
    /// add download task for the given ayah
    ///
    /// - Parameter ayah: the ayah that you want to download it
    fileprivate func download(ayah: Ayah) {
        let ayahNumber: Int64 = ayah.surah.id == 1 ? ayah.id : ayah.id + 1
        let downloadPath = URL.createFolder(folderName: "Quran/\(ayah.surah.id)")
        let fileName = "\(ayah.id).mp3"
        let url = Config.baseURL(forMode: currentMode) + "\(ayah.surah.id)/\(ayahNumber).mp3"
        manager.addDownloadTask(fileName, fileURL: url, destinationPath: downloadPath?.path ?? "", ayah: ayah)
    }
    
    
    /// cancel all old tasks if exist
    fileprivate func cancellOldTasksIfNeeded() {
        for (index, _) in manager.downloadingArray.enumerated() {
            manager.cancelTaskAtIndex(index)
        }
        
        manager.downloadingArray.removeAll()
        downloadQueue.removeAll()
    }
}

//MARK: - DownloadView
extension DownloadManager {
    
    /// called when the user click on cancel button at the download view
    fileprivate func downloadViewOnShouldCancelDownloading() {
        cancellOldTasksIfNeeded()
        downloadView.hide()
    }
    
    /// called when the user click on pause button at the download view
    fileprivate func downloadViewOnShouldPauseDownloading() {
        for (index, _) in manager.downloadingArray.enumerated() {
            manager.pauseDownloadTaskAtIndex(index)
        }
    }
    
    /// called when the user click on resume button at the download view
    fileprivate func downloadViewOnShouldResumeDownloading() {
        for (index, _) in manager.downloadingArray.enumerated() {
            manager.resumeDownloadTaskAtIndex(index)
        }
    }
}

//MARK: - URL
extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("eslam eslam")
                    print(error.localizedDescription)
                    return nil
                }
            }
            
            return filePath
        } else {
            return nil
        }
    }
}
