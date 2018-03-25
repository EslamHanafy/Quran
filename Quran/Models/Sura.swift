//
//  Sura.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/20/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

class Surah {
    var id: Int64
    var name: String
    var page: Int64
    var allAyah: [Ayah]
    
    init(id: Int64, name: String, page: Int64, allAyah: [Ayah] = []) {
        self.id = id
        self.allAyah = allAyah
        self.name = name
        self.page = page
    }
    
    init(fromRow row: Row) {
        let surahTable = Table("surah")
        let id = Expression<Int64>("id")
        let name = Expression<String>("name")
        let page = Expression<Int64>("page")
        
        self.id = row[surahTable[id]]
        self.name = row[surahTable[name]]
        self.page = row[surahTable[page]]
        self.allAyah = []
    }
}
