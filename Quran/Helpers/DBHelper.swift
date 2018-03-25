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
                allSurah.append(Surah(id: Int(surah[id]), name: surah[name], allAyah: []))
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
                allJuz.append(Juz(id: Int(row[juzTable[id]]), name: row[juzTable[name]], surah: Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: []), ayah: Ayah(id: Int(row[juzTable[ayah]]), content: "")))
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
    
    
    func getAllPages() -> [Page] {
        var pages: [Page] = []
        
        //tables
        let surahTable = Table("surah")
        let pagesTable = Table("pages")
        // columns
        let surahId = Expression<Int64>("surah_id")
        let id = Expression<Int64>("id")
        let ayah = Expression<Int64>("ayah_number")
        let name = Expression<String>("name")
        
      
        do {
            let data = try db.prepare(pagesTable.join(surahTable, on: pagesTable[surahId] == surahTable[id]))
            
            for (index, row) in data.enumerated() {
                var allSurah: [Surah] = []
                //FIXME: - split this code to another function
                /*
                if let next = data.first(where: { $0[pagesTable[id]] == (row[pagesTable[id]] + 1) }) {
                    allSurah = getAllAyahInPage(startingFromSurah: row[pagesTable[surahId]], toSurah: next[pagesTable[surahId]], andStartingFromAyah: row[pagesTable[ayah]], toAyah: next[pagesTable[ayah]])
                }else {
                    allSurah = getAllAyahInPage(startingFromSurah: row[pagesTable[surahId]], toSurah: 0, andStartingFromAyah: row[pagesTable[ayah]], toAyah: 0)
                }
                */
                pages.append(Page(id: Int(row[pagesTable[id]]), juz: self.getJuz(forSurah: Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: [])), allSurah: allSurah))
                
            }
            
        } catch {
            print("the error in gitting pages is: \(error.localizedDescription)")
        }
        
        
        return pages
    }
    
    func getAllAyahInPage(startingFromSurah startSurah: Int64, toSurah endSurah: Int64, andStartingFromAyah startAyah: Int64, toAyah endAyah: Int64) -> [Surah] {
        var allSurah: [Surah] = []
        
        // tables
        let ayahTable = Table("ayah")
        let surahTable = Table("surah")
        // columns
        let surahId = Expression<Int64>("surah_id")
        let number = Expression<Int64>("number")
        let text = Expression<String>("text")
        let name = Expression<String>("name")
        let id = Expression<Int64>("id")
        
        var query: QueryType!
        
        if startSurah != endSurah && endSurah != 0 {
            query = ayahTable.join(surahTable, on: surahId == surahTable[id]).where( ayahTable[surahId] >= startSurah && ayahTable[surahId] < endSurah )
        }else {
            if endSurah == 0 {
                query = ayahTable.join(surahTable, on: surahId == surahTable[id]).where( ayahTable[surahId] >= startSurah )
            }else {
                query = ayahTable.join(surahTable, on: surahId == surahTable[id]).where( ayahTable[surahId] == startSurah )
            }
        }
        
        do {
            let data = try db.prepare(query)
            
            for row in data {
                var sura: Surah!
                // get the last sura or add new one if needed
                if let _sura: Surah = allSurah.popLast() {
                    if (_sura.allAyah.last?.id ?? 0) > Int(row[ayahTable[number]]) {
                        allSurah.append(_sura)
                        sura = Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: [])
                    }else {
                        sura = _sura
                    }
                }else {
                    sura = Surah(id: Int(row[surahTable[id]]), name: row[surahTable[name]], allAyah: [])
                }
                //add current ayah to surah id needed
                if Int64(sura.id) == endSurah {
                    if row[ayahTable[number]] < endAyah && row[ayahTable[number]] >= startAyah {
                        sura.allAyah.append(Ayah(id: Int(row[ayahTable[number]]), content: row[ayahTable[text]]))
                    }
                }else {
                    if sura.id == startSurah {
                        if row[ayahTable[number]] >= startAyah {
                            sura.allAyah.append(Ayah(id: Int(row[ayahTable[number]]), content: row[ayahTable[text]]))
                        }
                    }else {
                        sura.allAyah.append(Ayah(id: Int(row[ayahTable[number]]), content: row[ayahTable[text]]))
                    }
                }
                //add current sura to all surah array
                allSurah.append(sura)
            }
            
        } catch  {
            print("the error in getting all ayah in page is: \(error.localizedDescription)")
        }
        
        return allSurah
    }
    
    func getJuz(forSurah surah: Surah) -> Juz {
        return Juz(id: 0, name: "", surah: surah, ayah: Ayah(id: 0, content: ""))
    }
}
