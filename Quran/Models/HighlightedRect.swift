//
//  HighLightedRect.swift
//  Quran
//
//  Created by Eslam Hanafy on 5/26/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

struct HighlightedRect: Equatable {
    var rect: CGRect
    var type: HighlightType
    var ayah: Ayah
    
    static func ==(lhs: HighlightedRect, rhs: HighlightedRect) -> Bool {
        return lhs.rect == rhs.rect && lhs.type == rhs.type && lhs.ayah.id == rhs.ayah.id
    }
}
