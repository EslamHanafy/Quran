//
//  QuranManager+AVAudioPlayer.swift
//  Quran
//
//  Created by Eslam on 4/10/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import AVFoundation
import Toast_Swift

extension QuranManager {
    
    /// The ayah that come after current ayah in the quran
    var nextAyah: (ayah: Ayah?, pagePosition: PagePosition)? {
        get {
            guard let old = currentAyah, let currentPage = page(forAyah: old) else {
                return nil
            }
            
            for (surahIndex, surah) in currentPage.page.allSurah.enumerated() {
                for (ayahIndex, ayah) in surah.allAyah.enumerated() {
                    //get the current ayah
                    if ayah.dbId == old.dbId {
                        //check if the next ayah should be in the same surah as the current ayah or not
                        if ayahIndex < surah.allAyah.count - 1 {
                            // the next ayah in the same surah
                            return (surah.allAyah[ayahIndex + 1], .currentPage)
                        }else {
                            // so next ayah should be in the next surah
                            if surahIndex < currentPage.page.allSurah.count - 1 {
                                // check if next surah at the same page or not
                                if currentPage.page.allSurah[surahIndex + 1].allAyah.count > 0 {
                                    // the next ayah in the next surah at the same page
                                    return (currentPage.page.allSurah[surahIndex + 1].allAyah.first, .currentPage)
                                }else {
                                    // the next ayah should be at the next page
                                    if currentPage.index < pages.count - 1 {
                                        return (pages[currentPage.index + 1].allSurah.first?.allAyah.first, .nextPage)
                                    }
                                }
                            } else {
                                // so next ayah should be at the next page
                                if currentPage.index < pages.count - 1 {
                                    return (pages[currentPage.index + 1].allSurah.first?.allAyah.first, .nextPage)
                                }
                            }
                        }
                        
                        break
                    }
                }
            }
            
            return nil
        }
    }
    
    
    /// The ayah that come before current ayah in the quran
    var previousAyah: (ayah: Ayah?, pagePosition: PagePosition)? {
        get {
            guard let old = currentAyah, let currentPage = page(forAyah: old) else {
                return nil
            }
            
            for (surahIndex, surah) in currentPage.page.allSurah.enumerated() {
                for (ayahIndex, ayah) in surah.allAyah.enumerated() {
                    //get the current ayah
                    if ayah.dbId == old.dbId {
                        //check if the previous ayah should be in the same surah as the current ayah or not
                        if ayahIndex > 0 {
                            // the previous ayah in the same surah
                            return (surah.allAyah[ayahIndex - 1], .currentPage)
                        }else {
                            // so previous ayah should be in the previous surah
                            if surahIndex > 0 {
                                // check if previous surah at the same page or not
                                if currentPage.page.allSurah[surahIndex - 1].allAyah.count > 0 {
                                    // the previous ayah in the previous surah at the same page
                                    return (currentPage.page.allSurah[surahIndex - 1].allAyah.last, .currentPage)
                                }else {
                                    // the previous ayah should be at the previous page
                                    if currentPage.index > 0 {
                                        return (pages[currentPage.index - 1].allSurah.last?.allAyah.last, .previousPage)
                                    }
                                }
                            } else {
                                // so next ayah should be at the next page
                                if currentPage.index > 0 {
                                    return (pages[currentPage.index - 1].allSurah.last?.allAyah.last, .previousPage)
                                }
                            }
                        }
                        
                        break
                    }
                }
            }
            
            return nil
        }
    }
    
    
    
    /// play the given ayah
    ///
    /// - Parameter ayah: Ayah object that contain the ayah data
    func play(ayah: Ayah) {
        //resume the current ayah if needed
        if ayah.dbId == (currentAyah?.dbId ?? 0) && player != nil && (player?.currentTime ?? 0) > 0 {
            return resumeCurrentAyah()
        }
        
        self.currentAyah = ayah
        
        guard let path = ayah.audioFiles.path(forMode: audioMode) else {
            getCurrentViewController()?.view.makeToast("عذرا لا يوجد ملف صوتى للاية رقم " + String(ayah.id) + " من سورة " + String(ayah.surah.name))
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            ayah.isPlaying = true
            currentTextView.handlePlayActionForAyah(ayah)
        } catch {
            print("the error in playing ayah: \(ayah.id) is: \(error)")
        }
    }
    
    
    /// play next ayah in the quran if exist
    func playNextAyahIfNeeded() {
        if let ayah = currentAyah {
            ayah.isPlaying = false
            self.currentTextView.handlePlayActionForAyah(ayah)
            
            if let next = nextAyah {
                if let ayah = next.ayah {
                    if next.pagePosition == .nextPage {
                        currentQuranController.scrollToNextPage()
                    }
                    
                    delay(timeBetweenAyah, closure: {
                        self.play(ayah: ayah)
                    })
                }
            }
        }
    }
    
    
    /// resume current ayah
    func resumeCurrentAyah() {
        player?.play()
        if let ayah = currentAyah {
            ayah.isPlaying = true
            currentTextView.handlePlayActionForAyah(ayah)
        }
    }
    
    /// pause current ayah
    func pauseCurrentAyah() {
        player?.pause()
        
        if let ayah = currentAyah {
            ayah.isPlaying = false
            currentTextView.handlePlayActionForAyah(ayah)
        }
    }
    
    /// play the previous ayah if exist
    func playPreviousAyahIfNeeded() {
        if let ayah = currentAyah {
            ayah.isPlaying = false
            self.currentTextView.handlePlayActionForAyah(ayah)
            
            if let prev = previousAyah {
                if let ayah = prev.ayah {
                    if prev.pagePosition == .nextPage {
                        currentQuranController.scrollToPreviousPage()
                    }
                    
                    delay(timeBetweenAyah, closure: {
                        self.play(ayah: ayah)
                    })
                }
            }
        }
    }
    
    /// get the page that represent the given ayah
    ///
    /// - Parameter ayah: Ayah object that contain the ayah data
    /// - Returns: page index in the pages array and the page object itself
    fileprivate func page(forAyah ayah: Ayah) -> (index: Int, page: Page)? {
        for (index, page) in pages.enumerated() {
            if page.id == currentAyah!.page {
                return (index, page)
            }
        }
        return nil
    }
}

//MARK: - AudioPlayerDelegate
extension QuranManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextAyahIfNeeded()
    }
}

//MARK: - PagePosition
enum PagePosition: String {
    case currentPage = "currentPage"
    case nextPage = "nextPage"
    case previousPage = "previousPage"
}
