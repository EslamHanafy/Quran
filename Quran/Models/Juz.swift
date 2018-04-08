//
//  Juz.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

open class Juz: NSObject, Codable {
    var id: Int64
    var name: String
    var surah: Surah
    var ayah: Ayah
    
    override init() {
        self.id = 0
        self.name = ""
        self.surah = Surah(id: 0, name: "", page: 0)
        self.ayah = Ayah(id: 0)
    }
    
    init(id: Int64, name: String, surah: Surah, ayah: Ayah) {
        self.ayah = ayah
        self.id = id
        self.surah = surah
        self.name = name
    }
    
    init(fromRow row: Row) {
        let juzTable = Table("juz")
        let id = Expression<Int64>("id")
        let ayah = Expression<Int64>("ayah_number")
        let name = Expression<String>("name")
        
        self.id = row[juzTable[id]]
        self.name = row[juzTable[name]]
        self.surah = Surah(fromRow: row)
        self.ayah = Ayah(id: row[juzTable[ayah]])
    }
}
