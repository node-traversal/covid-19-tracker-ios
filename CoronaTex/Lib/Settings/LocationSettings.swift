//
//  LocationSettings.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation

class LocationSettings: NSObject, NSCoding {
    var selectedState: String = ""
    
    override required init() { super.init() }
    
    required init?(coder: NSCoder) {
        super.init()
        self.decodeSettings(coder: coder)
    }
    
    convenience init(
        selectedState: String) {
        self.init()
        self.selectedState = selectedState
    }
           
    func getPersistentFolderName() -> String? {
        return nil
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(selectedState, forKey: PropertyKey.selectedState)
    }
        
    func decodeSettings(coder: NSCoder) {
        self.selectedState = coder.decodeObject(forKey: PropertyKey.selectedState) as? String ?? ""
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
                print("Couldn't read settings in \(folder).")
            }
        }
        
        return settings
    }
    
    fileprivate enum PropertyKey {
        static let selectedState = "selectedState"
    }
    
    private func getFolder() -> String {
        guard let folder = getPersistentFolderName() else {
            fatalError("No settings folder specified")
        }
        return folder
    }
}
