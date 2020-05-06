//
//  LocationSettings.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation
import CoreLocation

class LocationSettings: NSObject, NSCoding {
    var selectedState: String = ""
    var userLocation: CLLocation?
    
    override required init() { super.init() }
    
    required init?(coder: NSCoder) {
        super.init()
        self.decodeSettings(coder: coder)
    }
    
    convenience init(
        selectedState: String,
        userLocation: CLLocation?) {
        self.init()
        self.selectedState = selectedState
        self.userLocation = userLocation
    }
           
    func getPersistentFolderName() -> String? {
        return nil
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(selectedState, forKey: PropertyKey.selectedState)
        coder.encode(userLocation, forKey: PropertyKey.userLocation)
    }
        
    func decodeSettings(coder: NSCoder) {
        self.selectedState = coder.decodeObject(forKey: PropertyKey.selectedState) as? String ?? ""
        self.userLocation = coder.decodeObject(forKey: PropertyKey.userLocation) as? CLLocation
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
            print("Failed to save settings to: \(folder)!")
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
