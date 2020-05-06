//
//  MapSettings.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation

class MapSettings: LocationSettings {
    var milesToUser: Int = 0
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
                
        coder.encode(self.milesToUser, forKey: PropertyKey.milesToUser)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init()
        super.decodeSettings(coder: coder)

        self.milesToUser = coder.decodeInteger(forKey: PropertyKey.milesToUser)
    }
    
    override func getPersistentFolderName() -> String {
        return "MapSettings"
    }
    
    fileprivate enum PropertyKey {
        static let milesToUser = "milesToUser"
    }
}
