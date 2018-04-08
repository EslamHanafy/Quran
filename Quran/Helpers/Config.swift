//
//  Config.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/8/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation

struct Config {
    static let baseNormalURL: String = "http://quran.magdsoft.com/files/normal/"
    static let baseMemorizelURL: String = "http://quran.magdsoft.com/files/memorizing/"
    static let baseLearnlURL: String = "http://quran.magdsoft.com/files/learning/"
    
    
    /// get base url for the given AudioMode
    ///
    /// - Parameter mode: the wanted mode
    /// - Returns: String that represent base url for the given mode
    static func baseURL(forMode mode: AudioMode) -> String {
        switch mode {
        case .learn:
            return Config.baseLearnlURL
        case .memorize:
            return Config.baseMemorizelURL
        default:
            return Config.baseNormalURL
        }
    }
}
