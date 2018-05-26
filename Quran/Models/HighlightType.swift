//
//  HighlightType.swift
//  Quran
//
//  Created by Eslam Hanafy on 5/26/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

enum HighlightType {
    case select
    case bookmark
    case reading

    /// the highlight color for current type
    var color: UIColor {
        get {
            switch self {
            case .select:
                return hexStringToUIColor(hex: "AA7942", withAlpha: 0.5)
            case .bookmark:
                return hexStringToUIColor(hex: "FF2600", withAlpha: 0.5)
            default:
                return hexStringToUIColor(hex: QuranManager.manager.isNightMode ? "FF6138" : "0881A3", withAlpha: 0.5)
            }
        }
    }
    
}
