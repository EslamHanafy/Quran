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
    
    init(id: Int64, content: String = "") {
        self.id = id
        self.content = content
    }
    
    init(fromRow row: Row) {
        let ayahTable = Table("ayah")
        let number = Expression<Int64>("number")
        let text = Expression<String>("text")
        
        self.id = row[ayahTable[number]]
        self.content = row[ayahTable[text]]
    }
}
