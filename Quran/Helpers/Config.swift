//
//  Config.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/8/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation

struct Config {
    static let baseNormalURL: String = "https://quran.magdsoft.com/files/normal/"
    static let baseMemorizelURL: String = "https://quran.magdsoft.com/files/memorizing/"
    static let baseLearnlURL: String = "https://quran.magdsoft.com/files/learning/"
    static let APPSTORE_URL: String = "https://itunes.apple.com/us/app/%D8%A7%D9%84%D9%82%D8%B1%D8%A3%D9%86-%D8%A7%D9%84%D9%83%D8%B1%D9%8A%D9%85-%D9%84%D9%84%D8%B3%D9%8A%D8%AF-%D8%A7%D9%84%D9%85%D8%B9%D9%84%D9%85-%D8%AD%D9%8A%D8%AF/id1372553920?ls=1&mt=8"
    
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
