//
//  AudioMode.swift
//  Quran
//
//  Created by Eslam on 4/7/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation

enum AudioMode: String {
    case normal = "normal"
    case memorize = "memorize"
    case learn = "learn"
    
    func selectedIndex() -> Int {
        switch self {
        case .normal:
            return 0
        case .memorize:
            return 1
        default:
            return 2
        }
    }
}
