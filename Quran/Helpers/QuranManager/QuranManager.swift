//
//  QuranManager.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/3/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import AVFoundation

class QuranManager: NSObject {
    public static let manager: QuranManager = QuranManager()
    
    /// all quran pages
    var pages: [Page] = []
    /// all quran juz
    var allJuz: [Juz] = []
    /// all quran surah
    var AllSurah: [Surah] = []
    
    var audioMode: AudioMode = .normal
    
    var player: AVAudioPlayer? = nil
    
    var currentTextView: QuranTextView!
    
    var currentQuranController: QuranViewController!
    
    var currentAyah: Ayah? = nil
    
    var timeBetweenAyah: Double = 0.3
    
    override init() {
        super.init()
        
        self.AllSurah = DBHelper.shared.getAllSurah()
        self.pages = DBHelper.shared.getAllPages()
        
        backgroundQueue {
            self.allJuz = DBHelper.shared.getAllJuz()
        }
    }
    
    
    
    /// begin the manager background tasks
    func begin() {
        backgroundQueue {
            print("start updating all pages")
            self.pages.forEach({ $0.updateData() })
            print("end updating all pages")
        }
    }
    
    
    /// display the download options for the given Ayah
    ///
    /// - Parameter ayah: Ayah object that contain the ayah data
    func showDownloadOptions(forAyah ayah: Ayah) {
        let alert = UIAlertController(title: "تحميل ملفات الصوت", message: "اختر الملفات الصوتية التى تريد تنزيلها", preferredStyle: .actionSheet)
        // download the whole quran
        alert.addAction(UIAlertAction(title: "كل السور", style: .destructive, handler: { (_) in
            DownloadManager.shared.downloadQuran(forMode: self.audioMode)
        }))
        // download surah
        alert.addAction(UIAlertAction(title: "كل ايات هذه السورة", style: .default, handler: { (_) in
            DownloadManager.shared.download(surah: ayah.surah, forMode: self.audioMode)
        }))
        // download page
        alert.addAction(UIAlertAction(title: "كل ايات هذه الصفحة", style: .default, handler: { (_) in
            if let index = self.pages.index(where: { $0.id == ayah.page }) {
                DownloadManager.shared.download(page: self.pages[index], forMode: self.audioMode)
            }
        }))
        // download ayah
        alert.addAction(UIAlertAction(title: "هذه الاية فقط", style: .default, handler: { (_) in
            DownloadManager.shared.download(ayah: ayah, forMode: self.audioMode)
        }))
        
        alert.addAction(UIAlertAction(title: "الغاء", style: .cancel, handler: nil))
        
        getCurrentViewController()?.present(alert, animated: true, completion: nil)
    }
}
