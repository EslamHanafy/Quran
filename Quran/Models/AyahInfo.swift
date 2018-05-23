//
//  AyahInfo.swift
//  Quran
//
//  Created by Eslam on 5/23/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import SQLite

class AyahInfo: Codable {
    var ayah: Ayah
    var glyphs: [Glyph]
    
    init() {
        self.ayah = Ayah(id: 0)
        self.glyphs = []
    }
    
    init(forAyah ayah: Ayah) {
        self.ayah = ayah
        self.glyphs = DBHelper.shared.getGlyphs(forAyah: ayah)
    }
}
