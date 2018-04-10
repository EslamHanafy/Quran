//
//  QuranManager+AVAudioPlayer.swift
//  Quran
//
//  Created by Eslam on 4/10/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import AVFoundation

extension QuranManager {
    
    func play(ayah: Ayah) {
        self.currentAyah = ayah
        
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: ayah.audioFiles.path(forMode: audioMode)!))
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            ayah.isPlaying = true
        } catch {
            print("the error in playing ayah: \(ayah.id) is: \(error)")
        }
    }
    
    func getNextAyah() -> Ayah? {
        guard let old = currentAyah else {
            return nil
        }
        
        var currentPage:(index: Int, page: Page)!
        
        for (index, page) in pages.enumerated() {
            if page.id == old.page {
                currentPage = (index, page)
            }
        }
        
        
        for (index, surah) in currentPage.page.allSurah.enumerated() {
            for (ayahIndex, ayah) in surah.allAyah.enumerated() {
                if ayah.dbId == old.dbId {
                    
                    if ayahIndex < surah.allAyah.count - 1 {
                        // the next ayah in the same surah
                        return surah.allAyah[ayahIndex + 1]
                    }else {
                        if index < currentPage.page.allSurah.count - 1 {
                            
                            if currentPage.page.allSurah[index + 1].allAyah.count > 0 {
                                // the next ayah in the next surah
                                return currentPage.page.allSurah[index + 1].allAyah.first
                            }else {
                                // the next ayah should be in the next page
                                //TODO: - should move user to the next cell
                                if currentPage.index < pages.count - 1 {
                                    return pages[currentPage.index].allSurah.first?.allAyah.first
                                }
                            }
                        } else {
                            // the next ayah should be in the next page
                            if currentPage.index < pages.count - 1 {
                                //TODO: - should move user to the next cell
                                return pages[currentPage.index].allSurah.first?.allAyah.first
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

//MARK: - AudioPlayerDelegate
extension QuranManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let ayah = currentAyah {
            ayah.isPlaying = false
            self.currentTextView.hamdePlayActionForAyah(ayah)
            
            if let next = getNextAyah() {
                play(ayah: next)
            }
        }
    }
}
