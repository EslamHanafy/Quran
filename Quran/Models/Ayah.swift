//
//  Ayah.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

class Ayah {
    var id: Int64
    var content: String
    var page: Int64
    
    init(id: Int64, content: String = "", page: Int64 = 0) {
        self.id = id
        self.content = content
        self.page = page
    }
    
    init(fromRow row: Row) {
        let ayahTable = Table("ayah")
        let number = Expression<Int64>("number")
        let text = Expression<String>("text")
        let pageNumber = Expression<Int64>("page")
        
        self.id = row[ayahTable[number]]
        self.content = row[ayahTable[text]]
        self.page = row[ayahTable[pageNumber]]
    }
}
