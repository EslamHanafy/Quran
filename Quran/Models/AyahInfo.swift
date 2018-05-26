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
    
    var rects: [CGRect] {
        get {
            var rects: [CGRect] = []
            
            let groupedGlypghs = Dictionary(grouping: glyphs, by: { return $0.line })
            for (_, newGlyphs) in groupedGlypghs {
                var minX: CGFloat = CGFloat.greatestFiniteMagnitude
                var maxX: CGFloat = 0
                var minY: CGFloat = CGFloat.greatestFiniteMagnitude
                var maxY: CGFloat = 0
                
                for glyph in newGlyphs {
                    if glyph.minX < minX {
                        minX = glyph.minX
                    }
                    
                    if glyph.maxX > maxX {
                        maxX = glyph.maxX
                    }
                    
                    if glyph.minY < minY {
                        minY = glyph.minY
                    }
                    
                    if glyph.maxY > maxY {
                        maxY = glyph.maxY
                    }
                }
                
                rects.append(CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY))
            }
            return rects
        }
    }
    
    init() {
        self.ayah = Ayah(id: 0)
        self.glyphs = []
    }
    
    init(forAyah ayah: Ayah) {
        self.ayah = ayah
        self.glyphs = DBHelper.shared.getGlyphs(forAyah: ayah)
    }
    
    func contain(point: CGPoint, withImageScale scale: ImageScale) -> Bool {
        for glyph in glyphs {
            if glyph.rect.applying(CGAffineTransform(scaleX: scale.width, y: scale.height)).contains(point) {
                return true
            }
        }
        
        return false
    }
}
