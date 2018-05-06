//
//  SearchResult.swift
//  Quran
//
//  Created by Eslam Hanafy on 5/6/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

class SearchResult: CustomStringConvertible {
    var description: String {
        return "ayah number: \(ayah.id), ayah text: \(ayah.content), page number: \(page.id), surah name: \(surah.name), surah number: \(surah.id)"
    }
    
    var ayah: Ayah
    var surah: Surah
    var page: Page
    
    init(ayah: Ayah, surah: Surah, page: Page) {
        self.ayah = ayah
        self.surah = surah
        self.page = page
    }
    
    init(fromRow row: Row) {
        let ayahTable = Table("ayah")
        let page = Expression<Int64>("page")
        
        self.ayah = Ayah(fromRow: row)
        self.surah = Surah(fromRow: row)
        self.page = Page(id: row[ayahTable[page]], startingAyah: 0, juz: Juz(id: 0, name: "", surah: surah, ayah: ayah))
    }
}
