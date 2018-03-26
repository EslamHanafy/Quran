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
            print("the error in getting surah is: \(error)")
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
            print("the error in getting juz is: \(error)")
        }
        
        return allJuz
    }
    /*
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
            print("the error in getting all ayah is: \(error)")
        }
        
        return allAyah
    }
    */
    
    func getAllPages() -> [Page] {
        var pages: [Page] = []
        
        //tables
        let surahTable = Table("surah")
        let pagesTable = Table("pages")
        let juzTable = Table("juz")
        // columns
        let surahId = Expression<Int64>("surah_id")
        let id = Expression<Int64>("id")
        let juzId = Expression<Int64>("juz_id")
      
        do {
            let data = try db.prepare(pagesTable.join(surahTable, on: pagesTable[surahId] == surahTable[id]).join(juzTable, on: pagesTable[juzId] == juzTable[id]))
            
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
            print("the error in getting all ayah in page is: \(error)")
        }
        
        return allSurah
    }

}

/*
 func updateJuzInPages() {
 let pageTable = Table("pages")
 let juz = Expression<Int64>("juz_id")
 let id = Expression<Int64>("id")
 
 var allJuz: [Int64: [Int64]] = [Int64: [Int64]]()
 
 allJuz[1] = Array(1...21)
 allJuz[2] = Array(22...41)
 allJuz[3] = Array(42...61)
 allJuz[4] = Array(62...81)
 allJuz[5] = Array(82...101)
 allJuz[6] = Array(102...120)
 allJuz[7] = Array(121...141)
 allJuz[8] = Array(142...161)
 allJuz[9] = Array(162...181)
 allJuz[10] = Array(182...200)
 allJuz[11] = Array(201...221)
 allJuz[12] = Array(222...241)
 allJuz[13] = Array(242...261)
 allJuz[14] = Array(262...281)
 allJuz[15] = Array(282...301)
 allJuz[16] = Array(302...321)
 allJuz[17] = Array(322...341)
 allJuz[18] = Array(342...361)
 allJuz[19] = Array(362...381)
 allJuz[20] = Array(382...401)
 allJuz[21] = Array(402...421)
 allJuz[22] = Array(422...441)
 allJuz[23] = Array(442...461)
 allJuz[24] = Array(462...481)
 allJuz[25] = Array(482...501)
 allJuz[26] = Array(502...521)
 allJuz[27] = Array(522...541)
 allJuz[28] = Array(542...561)
 allJuz[29] = Array(562...581)
 allJuz[30] = Array(582...604)
 
 do {
 for (number, range) in allJuz {
 try db.run(pageTable.filter(range.contains(id)).update(juz <- number))
 }
 } catch {
 print(error)
 }
 
 }
 */

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

/*func updatePage(forAyah ayah: Int64, withPage page: Int64) {
 let ayahTable = Table("ayah")
 let id = Expression<Int64>("id")
 let pageNumber = Expression<Int64?>("page")
 
 do {
 if try db.run(ayahTable.filter(id == ayah).update(pageNumber <- page)) > 0 {
 print("ayah with id: \(ayah) updated successfully with page: \(page)")
 }
 } catch {
 print("the error in update surah page number is: \(error.localizedDescription)")
 }
 }*/

/*
 func getJuz(forPage page: Page) -> Juz {
 let juzTable = Table("juz")
 let surah = Expression<Int64>("surah_id")
 let ayah = Expression<Int64>("ayah_number")
 let name = Expression<String>("name")
 let id = Expression<Int64>("id")
 
 let query = juzTable.filter( surah >= page.allSurah.first!.id && ayah >= page.startingAyah)
 
 do {
 let data = try db.prepare(query)
 
 for row in data {
 //                print("juz row is: \(row[id])")
 if row[surah] == page.allSurah.first!.id {
 if row[ayah] == page.startingAyah {
 return Juz(id: row[id], name: row[name], surah: page.allSurah.first!, ayah: page.allSurah.first!.allAyah.first!)
 }else{
 if let next = page.nextPage {
 if row[ayah] < next.startingAyah {
 return Juz(id: row[id], name: row[name], surah: page.allSurah.first!, ayah: page.allSurah.first!.allAyah.first!)
 }
 }
 return getData(forJuz: row[id] - 1)
 }
 }
 
 if row[surah] > page.allSurah.first!.id {
 return getData(forJuz: row[id] - 1)
 }
 }
 
 } catch {
 print("the error in getting juz for page is: \(error)")
 }
 
 return Juz(id: 0, name: "", surah: Surah(id: 0, name: "", page: 0), ayah: Ayah(id: 0, content: ""))
 }
 */

/*
 func getData(forJuz juz: Int64) -> Juz {
 let juzTable = Table("juz")
 let surahTable = Table("surah")
 let id = Expression<Int64>("id")
 let surah = Expression<Int64>("surah_id")
 
 do {
 if let data = try db.pluck(juzTable.join(surahTable, on: juzTable[surah] == surahTable[id]).filter( juzTable[id] == juz)) {
 return Juz(fromRow: data)
 }
 } catch {
 print("the error in getting data for juz with id: \(juz) is: \(error)")
 }
 
 return Juz(id: 0, name: "", surah: Surah(id: 0, name: "", page: 0), ayah: Ayah(id: 0, content: ""))
 }*/
