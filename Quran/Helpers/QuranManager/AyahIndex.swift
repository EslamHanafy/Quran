//
//  AyahIndex.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/3/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation

class AyahIndex {
    var ayah: Int
    var surah: Int
    var page: Int
    
    init (string: String) {
        let arr = string.split(separator: ",")
        self.ayah = Int(arr[1])!
        self.surah = Int(arr[0])!
        self.page = Int(arr[2])!
    }
    
    init(ayah: Int, surah: Int, page: Int) {
        self.ayah = ayah
        self.surah = surah
        self.page = page
    }
}
