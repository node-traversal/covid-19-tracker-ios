//
//  LocationSettings.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation
import CoreLocation

class NamedLocation: NSObject, NSCoding {
    var name: String = ""
    var location: CLLocation
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: NamedLocationKey.name)
        coder.encode(location, forKey: NamedLocationKey.location)
    }
    
    init(name: String, location: CLLocation) {
        self.name = name
        self.location = location
    }
    
    required convenience init?(coder: NSCoder) {
        guard let location = coder.decodeObject(forKey: NamedLocationKey.location) as? CLLocation else {
            return nil
        }
        let name = coder.decodeObject(forKey: NamedLocationKey.name) as? String ?? ""
        self.init(name: name, location: location)
    }
    
    fileprivate enum NamedLocationKey {
        static let name = "locationName"
        static let location = "NamedLocation"
    }
}

class LocationSettings: NSObject, NSCoding {
    var selectedState: String = ""
    var location: NamedLocation?
    
    override required init() { super.init() }
    
    required init?(coder: NSCoder) {
        super.init()
        self.decodeSettings(coder: coder)
    }
    
    convenience init(
        selectedState: String,
        userLocation: NamedLocation?) {
        self.init()
        self.selectedState = selectedState
        self.location = userLocation
    }
           
    func getPersistentFolderName() -> String? {
        return nil
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(selectedState, forKey: PropertyKey.selectedState)
        coder.encode(location, forKey: PropertyKey.userLocation)
    }
        
    func decodeSettings(coder: NSCoder) {
        self.selectedState = coder.decodeObject(forKey: PropertyKey.selectedState) as? String ?? ""
        self.location = coder.decodeObject(forKey: PropertyKey.userLocation) as? NamedLocation
    }
    
    private func getArchiveUrl(folder: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(folder)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let folder = getFolder()
        let url = getArchiveUrl(folder: folder)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try data.write(to: url)
            print("Setting saved to: \(folder)")
        } catch {
            fatalError("Failed to save settings to: \(folder) \(error)")
        }
    }
    
    func load() -> Self {
        var settings = Self()
        let folder = getFolder()
        let url = getArchiveUrl(folder: folder)
        
        if let nsData = NSData(contentsOf: url) {
            do {
                let data = Data(referencing: nsData)

                if let loadedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Self {
                    settings = loadedData
                }
            } catch {
                print("Couldn't read settings in \(folder): \(error).")
            }
        }
        
        return settings
    }
    
    fileprivate enum PropertyKey {
        static let selectedState = "selectedState"
        static let userLocation = "userLocation"
    }
    
    private func getFolder() -> String {
        guard let folder = getPersistentFolderName() else {
            fatalError("No settings folder specified")
        }
        return folder
    }
}
