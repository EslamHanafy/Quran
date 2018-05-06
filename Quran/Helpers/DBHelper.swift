//
//  DBHelper.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/20/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite
import AEXML

class DBHelper {
    public static let shared: DBHelper = DBHelper()
    
    fileprivate let db = try! Connection(DBHelper.databasePath()) //Connection(Bundle.main.path(forResource: "Quran", ofType: "db")!)
    
    
    /// copy the database if needed from app bundle to documents folder and get the new database path
    ///
    /// - Returns: the new database path
    class func databasePath() -> String {
        // Move database file from bundle to documents folder
        
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return "" // Could not find documents URL
        }
        
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("Quran.sqlite")
        
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
            print("DB does not exist in documents folder")
            
            let documentsURL = Bundle.main.path(forResource: "Quran", ofType: "db")
            
            do {
                try fileManager.copyItem(atPath: documentsURL!, toPath: finalDatabaseURL.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
            
        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
        }
        
        return finalDatabaseURL.path
    }
    
    
    
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
                let juz = Juz(fromRow: row)
                juz.ayah = getAyah(forJuz: juz)
                allJuz.append(juz)
            }
        } catch {
            print("the error in getting juz is: \(error)")
        }
        
        return allJuz
    }
    
    
    /// get all quran pages without their ayah
    ///
    /// - Returns: all quran pages
    func getAllPages() -> [Page] {
        var pages: [Page] = []
        print("start gitting all pages")
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
        print("finish gitting all pages")
        return pages
    }
    
    
    
    /// get all ayah insed their surah for the given page boundary
    ///
    /// - Parameters:
    ///   - startSurah: number of first surah in the page
    ///   - endSurah: number of last surah in the page
    ///   - startAyah: number of first ayah for first surah in the page
    ///   - endAyah: number of last ayah for last surah in the page
    ///   - page: the page number
    /// - Returns: Surah array that contains all ayah for the given page
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
            //in some cases it should be < and other cases <=
            query = ayahTable.join(surahTable, on: surahId == surahTable[id]).where( ayahTable[surahId] >= startSurah && ayahTable[surahId] <= endSurah )
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
                    if startSurah == endSurah {
                        if row[ayahTable[number]] < endAyah && row[ayahTable[number]] >= startAyah {
                            sura.allAyah.append(Ayah(fromRow: row))
                        }
                    }else {
                        if row[ayahTable[number]] < endAyah {
                            sura.allAyah.append(Ayah(fromRow: row))
                        }
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

    
    /// get ayah data for juz
    ///
    /// - Parameter juz: Juz object that containt the juz data
    /// - Returns: Ayah object
    func getAyah(forJuz juz: Juz) -> Ayah {
        var ayah = juz.ayah
        
        let ayahTable = Table("ayah")
        let surahTable = Table("surah")
        let number = Expression<Int64>("number")
        let surahId = Expression<Int64>("surah_id")
        let id = Expression<Int64>("id")
        
        
        do {
            if let row = try db.pluck(ayahTable.join(surahTable, on: surahId == surahTable[id]).filter(surahId == juz.surah.id && number == juz.ayah.id)) {
                ayah = Ayah(fromRow: row)
            }
        } catch  {
            print("the error in getting ayah for juz is: \(error)")
        }
        
        return ayah
    }
    
    
    /// insert new bookmark in database using the ayah dbId
    ///
    /// - Parameter ayah: Ayah object that contain the ayah details
    func addBookMark(forAyah ayah: Ayah) {
        guard ayah.dbId != 0 else {
            return print("theer is no dbId found for this ayah")
        }
        
        let bookTable = Table("bookmarks")
        let ayahId = Expression<Int64>("ayah_id")
        let surahId = Expression<Int64>("surah_id")
        
        do {
            try db.run(bookTable.insert(ayahId <- ayah.dbId, surahId <- ayah.surah.id))
            updateBookMarkForAyah(withId: ayah.dbId, isMarked: true)
        } catch {
            print("the error in inserting new bookmark is: \(error)")
        }
    }
 
    
    /// get all stored bookmarks
    ///
    /// - Returns: array of BookMarks
    func getBookMarks() -> [BookMark] {
        var bookMarks: [BookMark] = []
        
        let marksTable = Table("bookmarks")
        let ayahTable = Table("ayah")
        let surahTable = Table("surah")
        let id = Expression<Int64>("id")
        let ayahId = Expression<Int64>("ayah_id")
        let surahId = Expression<Int64>("surah_id")
        
        do {
            let data = try db.prepare(marksTable.join(ayahTable, on: ayahId == ayahTable[id]).join(surahTable, on: marksTable[surahId] == surahTable[id]))
            for row in data {
                bookMarks.append(BookMark(fromRow: row))
            }
        } catch {
            print("error in get all bookmarks is: \(error)")
        }
        
        return bookMarks
    }
    
    
    /// get details for the surah with the same id
    ///
    /// - Parameter surahId: the surah id
    /// - Returns: Surah object that contain the surah data
    func getSurah(withId surahId: Int64) -> Surah {
        var surah: Surah = Surah(id: 0, name: "", page: 0)
        
        let surahTable = Table("surah")
        let name = Expression<String>("name")
        let id = Expression<Int64>("id")
        let page = Expression<Int64>("page")
        
        do {
            if let row = try db.pluck(surahTable.filter(id == surahId)) {
                surah = Surah(id: surahId, name: row[name], page: row[page])
            }
        } catch {
            print("error in get surah with id: \(surahId) is: \(error)")
        }
        
        return surah
    }
    
    
    /// delete the bookmark with the given id
    ///
    /// - Parameter markId: bookmark id
    func delete(bookMark mark: BookMark) {
        let marksTable = Table("bookmarks")
        let id = Expression<Int64>("id")
        
        do {
            try db.run(marksTable.filter(id == mark.id).delete())
            updateBookMarkForAyah(withId: mark.ayah.dbId, isMarked: false)
        } catch {
            print("error in delete bookmark with id: \(mark.id) is: \(error)")
        }
    }
    
    
    /// delete the bookmark for the given ayah
    ///
    /// - Parameter ayah: Ayah object that contain the ayah data
    func delete(bookmarkForAyah ayah: Ayah) {
        let marksTable = Table("bookmarks")
        let ayahId = Expression<Int64>("ayah_id")
        
        do {
            try db.run(marksTable.filter(ayahId == ayah.dbId).delete())
            updateBookMarkForAyah(withId: ayah.dbId, isMarked: false)
        } catch {
            print("error in delete bookmark for ayah with id: \(ayah.id) is: \(error)")
        }
    }
    
    /// update isBookMarked value for the given ayah
    ///
    /// - Parameters:
    ///   - ayahId: the ayah database id
    ///   - marked: true for is marked and false for not
    func updateBookMarkForAyah(withId ayahId: Int64, isMarked marked: Bool) {
        let ayahTable = Table("ayah")
        let id = Expression<Int64>("id")
        let isMarked = Expression<Int64?>("is_bookmarked")
        
        do {
            try db.run(ayahTable.filter(id == ayahId).update(isMarked <- Int64(marked.hashValue)))
        } catch {
            print("error in updateing isBookMarked for ayah with id: \(ayahId) is: \(error)")
        }
    }
    
    
    
    /// update the stored audio path for the given ayah and audio mode
    ///
    /// - Parameters:
    ///   - path: the new path
    ///   - ayah: the updated ayah
    ///   - mode: the audio mode
    func update(audioPath path: String, forAyah ayah: Ayah?, andMode mode: AudioMode) {
        guard let ayah = ayah else {
            return
        }
        
        let ayahTable = Table("ayah")
        let id = Expression<Int64>("id")
        let audio = Expression<String?>("audio_path_" + mode.rawValue)
        
        do {
            try db.run(ayahTable.filter(id == ayah.dbId).update(audio <- path))
        } catch {
            print("error in updateing audio path for ayah with id: \(ayah.dbId) is: \(error)")
        }
    }
    
    
    /// get all ayah in the given surah
    ///
    /// - Parameter surah: Surah object that contain the surah data
    /// - Returns: array of Ayah in this surah
    func getAllAyah(forSurah surah: Surah) -> [Ayah] {
        var allAyah: [Ayah] = []
        
        let ayahTable = Table("ayah")
        let surahTable = Table("surah")
        let surahId = Expression<Int64>("surah_id")
        let id = Expression<Int64>("id")
        
        do {
            let data = try db.prepare(ayahTable.join(surahTable, on: surahId == surahTable[id]).filter(ayahTable[surahId] == surah.id))
            for row in data {
                allAyah.append(Ayah(fromRow: row))
            }
        } catch  {
            print("the error in getting all ayah for surah \(surah.name) is: \(error)")
        }
        
        return allAyah
    }
    
    
    /// get whole ayah in the quran
    ///
    /// - Returns: array of Ayah
    func getAllAyah() -> [Ayah] {
        var allAyah: [Ayah] = []
        
        let ayahTable = Table("ayah")
        let surahTable = Table("surah")
        let surahId = Expression<Int64>("surah_id")
        let id = Expression<Int64>("id")
        
        do {
            let data = try db.prepare(ayahTable.join(surahTable, on: surahId == surahTable[id]))
            for row in data {
                allAyah.append(Ayah(fromRow: row))
            }
        } catch  {
            print("the error in getting all ayah in the quran is: \(error)")
        }
        
        return allAyah
    }
    
    
    /// get audio file path for the given mode and ayah
    ///
    /// - Parameters:
    ///   - ayah: Ayah object that contin the ayah data
    ///   - mode: the wanted audio mode
    /// - Returns: the audio path if exist
    func getPath(forAyah ayah: Ayah?, andMode mode: AudioMode) -> String? {
        guard let ayah = ayah else {
            return nil
        }
        
        let ayahTable = Table("ayah")
        let id = Expression<Int64>("id")
        let path = Expression<String?>("audio_path_" + mode.rawValue)
        do {
            if let row = try db.pluck(ayahTable.select(path).filter(id == ayah.dbId)) {
                return row[path]
            }
        } catch  {
            print("the error in getting path for ayah \(ayah.dbId) is: \(error)")
        }
        
        return nil
    }
    
    
    /// search for ayah that contain the given text
    ///
    /// - Parameter text: the search keyword
    /// - Returns: array of SearchResult
    func searchForAyah(withText text: String) -> [SearchResult] {
        var results: [SearchResult] = []
        
        let ayahTable = Table("ayah")
        let surahTable = Table("surah")
        let pageTable = Table("pages")
        let surahId = Expression<Int64>("surah_id")
        let page = Expression<Int64>("page")
        let ayahText = Expression<String>("text")
        let id = Expression<Int64>("id")
        
        do {
            let data = try db.prepare(ayahTable.filter(ayahText.like("%\(text)%")).join(pageTable, on: ayahTable[page] == pageTable[id]).join(surahTable, on: ayahTable[surahId] == surahTable[id]))
            for row in data {
                results.append(SearchResult(fromRow: row))
            }
        } catch {
            print("the error in searching for ayah with text: \(text), is: \(error)")
        }
        
        return results
    }
    
    func updateQuranFromXML() {
        guard let path = Bundle.main.path(forResource: "quran-simple-clean", ofType: "xml"),
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let xml = try? AEXMLDocument(xml: data)
        else {
            return print("there is no xml file found")
        }
        
        for surahXML in xml.root.children {
            for ayahXML in surahXML.children {
                print("surah name is: \(surahXML.attributes["index"]), ayah is: \(ayahXML.attributes["text"])")
                
            }
        }
        
    }
    
    /*
    func updateAyah(withNumber number: Int64) -> <#return type#> {
        <#function body#>
    }*/
}
