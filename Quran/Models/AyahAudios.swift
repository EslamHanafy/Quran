//
//  AyahAudios.swift
//  Quran
//
//  Created by Eslam on 4/7/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation

open class AyahAudios: NSObject, Codable {
    var normal: String? {
        get {
            return DBHelper.shared.getPath(forAyah: ayah, andMode: .normal)
        }
        
        set {
            DBHelper.shared.update(audioPath: newValue ?? "", forAyah: ayah, andMode: .normal)
        }
    }
    
    var memorize: String? {
        get {
            return DBHelper.shared.getPath(forAyah: ayah, andMode: .memorize)
        }
        
        set {
            DBHelper.shared.update(audioPath: newValue ?? "", forAyah: ayah, andMode: .memorize)
        }
    }
    
    var learn: String?{
        get {
            return DBHelper.shared.getPath(forAyah: ayah, andMode: .learn)
        }
        
        set {
            DBHelper.shared.update(audioPath: newValue ?? "", forAyah: ayah, andMode: .learn)
        }
    }
    
    var ayah: Ayah? = nil
    
    
    
    
    init(ayah: Ayah? = nil) {
        self.ayah = ayah
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
}
