//
//  QuranManager.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/3/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranManager {
    public static let manager: QuranManager = QuranManager()
    
    /// all quran pages
    var pages: [Page] = []
    /// all quran juz
    var allJuz: [Juz] = []
    /// all quran surah
    var AllSurah: [Surah] = []
    
    
    
    init() {
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
    
}
