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
    
    
    /// current audio mode for the playing audio files
    var audioMode: AudioMode = .normal {
        didSet {
            UserDefaults.standard.set(audioMode.rawValue, forKey: "audioMode")
        }
    }
    
    /// the audio player
    var player: AVAudioPlayer? = nil
    
    /// current text view that is displaying in the quran screen
    var currentTextView: QuranTextView!
    
    /// the current Quran screen class
    var currentQuranController: QuranViewController!
    
    /// current ayah that the audio player is playing
    var currentAyah: Ayah? = nil
    
    /// the delay time between each ayah
    var timeBetweenAyah: Double = 0.1
    
    /// the audio player volume degree
    var soundDegree: Float = 1.0 {
        didSet {
            UserDefaults.standard.set(soundDegree, forKey: "soundDegree")
            player?.volume = soundDegree
        }
    }
    
    /// the number of repeats for each ayah at learning mode
    var repeats: Int = 1
    
    /// the number of remaining repeats for current ayah at learning mode
    var remainingRepeats: Int = 0
    
    /// determine if the app should use the night mode or not
    var isNightMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isNightMode")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "isNightMode")
            currentQuranController?.reloadTheme()
        }
    }
    
    
    /// the main quran font color based on current theme
    var fontColor: UIColor {
        get {
            return isNightMode ? .white : .black
        }
    }
    
    
    override init() {
        super.init()
        
        self.AllSurah = DBHelper.shared.getAllSurah()
        self.pages = DBHelper.shared.getAllPages()
        
        self.audioMode = AudioMode(rawValue: UserDefaults.standard.value(forKey: "audioMode") as? String ?? "") ?? .normal
        self.soundDegree = UserDefaults.standard.value(forKey: "soundDegree") as? Float ?? 1.0
        
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
        
        alert.popoverPresentationController?.sourceView = QuranViewController.ayahOptions ?? self.currentQuranController.headerView
        
        getCurrentViewController()?.present(alert, animated: true, completion: nil)
    }
}
