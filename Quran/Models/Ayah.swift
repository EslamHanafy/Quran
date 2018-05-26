//
//  Ayah.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

class Ayah: NSObject, Codable {
    var id: Int64
    var content: String
    var page: Int64
    var dbId: Int64
    var isBookmarked: Bool
    var audioFiles: AyahAudios
    var surah: Surah
    var isPlaying: Bool = false
    var info: AyahInfo? = nil
    
    init(id: Int64, surah: Surah = Surah(id: 0), dbId: Int64 = 0, content: String = "", page: Int64 = 0, isBookmarked: Bool = false, audioFiles: AyahAudios = AyahAudios()) {
        self.id = id
        self.dbId = dbId
        self.surah = surah
        self.content = content
        self.page = page
        self.isBookmarked = isBookmarked
        self.audioFiles = audioFiles
    }
    
    init(fromRow row: Row) {
        let ayahTable = Table("ayah")
        let number = Expression<Int64>("number")
        let text = Expression<String>("text")
        let pageNumber = Expression<Int64>("page")
        let id = Expression<Int64>("id")
        let isMarked = Expression<Int64?>("is_bookmarked")
        
        self.id = row[ayahTable[number]]
        self.content = row[ayahTable[text]]
        self.page = row[ayahTable[pageNumber]]
        self.dbId = row[ayahTable[id]]
        self.surah = Surah(fromRow: row)
        self.isBookmarked = row[ayahTable[isMarked]] == 1
        
        self.audioFiles = AyahAudios(ayah: Ayah(id: 0))
        
        super.init()
        
        self.info = AyahInfo(forAyah: self)
        self.audioFiles = AyahAudios(ayah: self)
    }
    
    /// update the audio path for the given mode
    ///
    /// - Parameters:
    ///   - path: new audio path
    ///   - mode: the path audio mode
    func update(audioPath path: String, forMode mode: AudioMode)  {
        switch mode {
        case .learn:
            audioFiles.learn = path
        case .memorize:
            audioFiles.memorize = path
        default:
            audioFiles.normal = path
        }
    }
}
