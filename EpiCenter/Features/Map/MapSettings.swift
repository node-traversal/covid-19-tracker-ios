//
//  MapSettings.swift
//  EpiCenter
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation
import CoreLocation

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
    
    func isFiltered(county: CountyCaseData) -> Bool {
        var filtered = false
       
        if let location = location,
            let latitude = county.latitude,
            let longitude = county.longitude {
            let distance = Measurement(value: location.location.distance(from: CLLocation(latitude: latitude, longitude: longitude)), unit: UnitLength.meters)
            let miles = Int(distance.converted(to: .miles).value)
                                
            if milesToUser > 0 && miles > milesToUser {
                filtered = true
            }
        }
        
        return filtered
    }
    
    override func getPersistentFolderName() -> String {
        return "MapSettings"
    }
    
    fileprivate enum PropertyKey {
        static let milesToUser = "milesToUser"
    }
}
