//
//  Glyph.swift
//  Quran
//
//  Created by Eslam on 5/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import SQLite

struct Glyph: Equatable, Codable {
    
    var minX: CGFloat
    var minY: CGFloat
    var maxX: CGFloat
    var maxY: CGFloat
    var line: Int
    
    var rect: CGRect {
        get {
            return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }
    }
    
    init(fromRow row: Row) {
        let minX = Expression<Int64>("min_x")
        let minY = Expression<Int64>("min_y")
        let maxX = Expression<Int64>("max_x")
        let maxY = Expression<Int64>("max_y")
        let line = Expression<Int64>("line_number")
        
        self.minX = CGFloat(row[minX])
        self.minY = CGFloat(row[minY])
        self.maxX = CGFloat(row[maxX])
        self.maxY = CGFloat(row[maxY])
        self.line = Int(row[line])
    }
    
    
    static func ==(lhs: Glyph, rhs: Glyph) -> Bool {
        return lhs.minY == rhs.minY && lhs.minX == rhs.minX && lhs.maxX == rhs.maxX && lhs.maxY == rhs.maxY
    }
}
