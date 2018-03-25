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
        let page = Expression<Int64>("page")
        
        do {
            let data = try db.prepare(surahTable)
            for row in data {
                allSurah.append(Surah(id: row[id], name: row[name], page: row[page]))
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
        
        let query = juzTable.join(surahTable, on: surahId == surahTable[id])
        
        do {
            let data = try db.prepare(query)
            for row in data {
                allJuz.append(Juz(fromRow: row))
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
                allAyah.append(Ayah(id: row[number], content: row[text]))
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
        
      
        do {
            let data = try db.prepare(pagesTable.join(surahTable, on: pagesTable[surahId] == surahTable[id]))
            
            for row in data {
                pages.append(Page(fromRow: row))
            }
            
        } catch {
            print("the error in gitting pages is: \(error.localizedDescription)")
        }
        
        
        return prepare(pages: &pages)
    }
    
    private func prepare(pages: inout [Page]) -> [Page] {
        for (index, page) in pages.enumerated() {
            if index < (pages.count - 1) {
                page.nextPage = pages[index + 1]
//                if let sura = page.allSurah.first {
//                    page.allSurah = getAllAyahInRange(startingFromSurah: sura.id, toSurah: 0, andStartingFromAyah: page.startingAyah, toAyah: 0, forPage: page.id)
//                }
            }
        }
        
        return pages
    }
    
    func getAllAyahInRange(startingFromSurah startSurah: Int64, toSurah endSurah: Int64, andStartingFromAyah startAyah: Int64, toAyah endAyah: Int64, forPage page: Int64) -> [Surah] {
        var allSurah: [Surah] = []
        
        // tables
        let ayahTable = Table("ayah")
        let surahTable = Table("surah")
        // columns
        let surahId = Expression<Int64>("surah_id")
        let number = Expression<Int64>("number")
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
                if let _sura = allSurah.last {
                    if (_sura.allAyah.last?.id ?? 0) > Int(row[ayahTable[number]]) {
                        sura = Surah(fromRow: row)
                        //add current sura to all surah array
                        allSurah.append(sura)
                    }else {
                        sura = _sura
                    }
                }else {
                    sura = Surah(fromRow: row)
                    //add current sura to all surah array
                    allSurah.append(sura)
                }
                
                //add current ayah to surah id needed
                if sura.id == endSurah {
                    if row[ayahTable[number]] < endAyah && row[ayahTable[number]] >= startAyah {
                        sura.allAyah.append(Ayah(fromRow: row))
                    }
                }else {
                    if sura.id == startSurah {
                        if row[ayahTable[number]] >= startAyah {
                            sura.allAyah.append(Ayah(fromRow: row))
                        }
                    }else {
                        sura.allAyah.append(Ayah(fromRow: row))
                    }
                }
            }
            
        } catch  {
            print("the error in getting all ayah in page is: \(error.localizedDescription)")
        }
        
        return allSurah
    }

    /*
    func updateSurahPage(surah: Surah, page: Int64) {
        let surahTable = Table("surah")
        let id = Expression<Int64>("id")
        let pageNumber = Expression<Int64?>("page")
        do {
            if try db.run(surahTable.filter(id == surah.id && (pageNumber == nil || pageNumber == 0)).update(pageNumber <- page)) > 0 {
                print("surah with id: \(surah.id) updated successfully with page: \(page)")
            }
        } catch {
            print("the error in update surah page number is: \(error.localizedDescription)")
        }
        
    }
    */
    func getJuz(forSurah surah: Surah) -> Juz {
        return Juz(id: 0, name: "", surah: surah, ayah: Ayah(id: 0, content: ""))
    }
}
