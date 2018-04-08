//
//  AyahAudios.swift
//  Quran
//
//  Created by Eslam on 4/7/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation

open class AyahAudios: NSObject, Codable {
    var normal: String?
    var memorize: String?
    var learn: String?
    
    init(normal: String? = nil, memorize: String? = nil, learn: String? = nil) {
        self.normal = normal
        self.memorize = memorize
        self.learn = learn
    }
    
    
    /// get audio path for the given mode
    ///
    /// - Parameter mode: the AudioMode
    /// - Returns: the audio path for the given mode
    func path(forMode mode: AudioMode) -> String? {
        switch mode {
        case .learn:
            return learn
        case .memorize:
            return memorize
        default:
            return normal
        }
    }
    
    
    /// update the audio path for the given mode
    ///
    /// - Parameters:
    ///   - path: new audio path
    ///   - mode: the path audio mode
    func update(audioPath path: String, forMode mode: AudioMode)  {
        switch mode {
        case .learn:
            self.learn = path
        case .memorize:
            self.memorize = path
        default:
            self.normal = path
        }
    }
}
