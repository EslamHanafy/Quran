//
//  Page.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/24/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

class Page {
    var id: Int64
    var startingAyah: Int64
    var juz: Juz
    var allSurah: [Surah]
    var nextPage: Page? = nil
    
    init (id: Int64, startingAyah: Int64, juz: Juz, nextPage: Page? = nil, allSurah: [Surah] = []) {
        self.id = id
        self.allSurah = allSurah
        self.juz = juz
        self.nextPage = nextPage
        self.startingAyah = startingAyah
    }
    
    init(fromRow row: Row) {
        let pagesTable = Table("pages")
        let id = Expression<Int64>("id")
        let ayah = Expression<Int64>("ayah_number")
        
        let sura = Surah(fromRow: row)
        
        self.id = row[pagesTable[id]]
        self.startingAyah = row[pagesTable[ayah]]
        self.juz = DBHelper.shared.getJuz(forSurah: sura)
        self.allSurah = [sura]
    }
}
