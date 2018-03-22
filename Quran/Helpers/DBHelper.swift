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
        
        let surahTable = Table("surah")
        let id = Expression<Int64>("id")
        let name = Expression<String>("name")
        
        do {
            let data = try db.prepare(surahTable)
            for surah in data {
                allSurah.append(Surah(id: Int(surah[id]), name: surah[name]))
            }
        }catch {
            print("the error in getting surah is: \(error.localizedDescription)")
        }
        
        return allSurah
    }
    
    
    /// get all juz from database
    ///
    /// - Returns: array of Juz
    func getAllJuz() -> [Juz] {
        var allJuz: [Juz] = []
        
        let juzTable = Table("juz")
        let surahTable = Table("surah")
        let id = Expression<Int64>("id")
        let surahId = Expression<Int64>("surah_id")
        let ayah = Expression<Int64>("ayah_number")
        let name = Expression<String>("name")
        
        let query = juzTable.join(surahTable, on: surahId == surahTable[id])
        
        do {
            let data = try db.prepare(query)
            for row in data {
                allJuz.append(Juz(id: Int(row[juzTable[id]]), name: row[juzTable[name]], surah: Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]]), ayah: Ayah(id: Int(row[juzTable[ayah]]), content: "")))
            }
        } catch {
            print("the error in getting juz is: \(error.localizedDescription)")
        }
        
        return allJuz
    }
    
    func getAllAyah(forSurah surah: Surah) -> [Ayah] {
        var allAyah: [Ayah] = []
        
        let ayahTable = Table("ayah")
        let surahId = Expression<Int64>("surah_id")
        let number = Expression<Int64>("number")
        let text = Expression<String>("text")
        
        do {
            let data = try db.prepare(ayahTable.where(surahId == Int64(surah.id)))
            for row in data {
                allAyah.append(Ayah(id: Int(row[number]), content: row[text]))
            }
        } catch {
            print("the error in getting all ayah is: \(error.localizedDescription)")
        }
        
        return allAyah
    }
}
