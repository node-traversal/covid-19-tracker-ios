//
//  CasesChartSettings.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/25/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class CasesChartSettings: NSObject, NSCoding {
    var lastUpdated: String = ""
    var selectedState: String = ""
    var isPerCapita: Bool = false
    var isNewCases: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(lastUpdated, forKey: PropertyKey.lastUpdated)
        coder.encode(selectedState, forKey: PropertyKey.selectedState)
        coder.encode(isPerCapita, forKey: PropertyKey.isPerCapita)
        coder.encode(isNewCases, forKey: PropertyKey.newCases)
    }
    override init() { super.init() }
    
    convenience init(lastUpdated: String, selectedState: String, isPerCapita: Bool, isNewCases: Bool) {
        self.init()
        self.lastUpdated = lastUpdated
        self.selectedState = selectedState
        self.isPerCapita = isPerCapita
        self.isNewCases = isNewCases
    }
    
    required convenience init?(coder: NSCoder) {
        guard let lastUpdated = coder.decodeObject(forKey: PropertyKey.lastUpdated) as? String else {
            print("No lastUpdated in presistent data...")
            return nil
        }
        let selectedState = coder.decodeObject(forKey: PropertyKey.selectedState) as? String ?? ""
        
        let isPerCapita = coder.decodeBool(forKey: PropertyKey.isPerCapita)
        let isNewCases = coder.decodeBool(forKey: PropertyKey.newCases)
        
        self.init(lastUpdated: lastUpdated, selectedState: selectedState, isPerCapita: isPerCapita, isNewCases: isNewCases)
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveUrl = DocumentsDirectory.appendingPathComponent("CasesChartSettings")
    fileprivate enum PropertyKey {
        static let lastUpdated = "lastUpdated"
        static let selectedState = "selectedState"
        static let isPerCapita = "isPerCapita"
        static let newCases = "newCases"
    }
}
