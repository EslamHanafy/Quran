//
//  BookMark.swift
//  Quran
//
//  Created by Eslam on 4/2/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

open class BookMark: NSObject, Codable {
    var id: Int64
    var ayah: Ayah
    var surah: Surah
    
    init(id: Int64, ayah: Ayah, surah: Surah) {
        self.id = id
        self.ayah = ayah
        self.surah = surah
    }
    
    init(fromRow row: Row) {
        let marksTable = Table("bookmarks")
        let id = Expression<Int64>("id")
//        let ayahTable = Table("ayah")
//        let surahId = Expression<Int64>("surah_id")
        
        self.id = row[marksTable[id]]
        self.ayah = Ayah(fromRow: row)
        self.surah = Surah(fromRow: row) //DBHelper.shared.getSurah(withId: row[ayahTable[surahId]])
    }
}
