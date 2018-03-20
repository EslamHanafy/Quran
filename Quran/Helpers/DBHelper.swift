//
//  DBHelper.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/20/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

class DBHelper {
    public static let shared: DBHelper = DBHelper()
    
    fileprivate let db = try! Connection(Bundle.main.path(forResource: "Quran", ofType: "db")!)
    
    
    /// return all surah from database
    ///
    /// - Returns: array of Surah
    func getAllSurah()-> [Surah] {
        var allSurah: [Surah] = []
        
        let surahTable = Table("sura")
        let id = Expression<Int64>("id")
        let name = Expression<String>("name")
        
        for surah in try! db.prepare(surahTable) {
            allSurah.append(Surah(id: Int(surah[id]), name: surah[name]))
        }
        
        return allSurah
    }
}
