//
//  CasesChartSettings.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/25/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class CasesChartSettings: NSObject, NSCoding {
    static let topSelections = [5, 10, 25]
    static let daySelections = [[0, 0], [14, 0], [30, 0], [60, 0], [40, 30]]
    
    var lastUpdated: String = ""
    var selectedState: String = ""
    var isPerCapita: Bool = false
    var isNewCases: Bool = true
    var top: Int = 5
    var lastDays: Int = 0
    var limitDays: Int = 0
    
    static func findDayIndex(_ day: Int) -> Int {
        return CasesChartSettings.daySelections.firstIndex { $0[0] == day } ?? 0
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(lastUpdated, forKey: PropertyKey.lastUpdated)
        coder.encode(selectedState, forKey: PropertyKey.selectedState)
        coder.encode(isPerCapita, forKey: PropertyKey.isPerCapita)
        coder.encode(isNewCases, forKey: PropertyKey.newCases)
        coder.encode(top, forKey: PropertyKey.top)
        coder.encode(lastDays, forKey: PropertyKey.lastDays)
    }
    override init() { super.init() }
    
    convenience init(lastUpdated: String, selectedState: String, isPerCapita: Bool, isNewCases: Bool, top: Int, lastDays: Int) {
        self.init()
        self.lastUpdated = lastUpdated
        self.selectedState = selectedState
        self.isPerCapita = isPerCapita
        self.isNewCases = isNewCases
        self.top = top
        self.lastDays = lastDays
    }
    
    required convenience init?(coder: NSCoder) {
        guard let lastUpdated = coder.decodeObject(forKey: PropertyKey.lastUpdated) as? String else {
            print("No lastUpdated in presistent data...")
            return nil
        }
        let selectedState = coder.decodeObject(forKey: PropertyKey.selectedState) as? String ?? ""
        
        let isPerCapita = coder.decodeBool(forKey: PropertyKey.isPerCapita)
        let isNewCases = coder.decodeBool(forKey: PropertyKey.newCases)
        let top = coder.decodeObject(forKey: PropertyKey.top) as? Int ?? 5
        let lastDays = coder.decodeObject(forKey: PropertyKey.lastDays) as? Int ?? 0
        
        self.init(
            lastUpdated: lastUpdated,
            selectedState: selectedState,
            isPerCapita: isPerCapita,
            isNewCases: isNewCases,
            top: top,
            lastDays: lastDays
        )
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static let ArchiveUrl = getDocumentsDirectory().appendingPathComponent("CasesChartSettings")
    
    fileprivate enum PropertyKey {
        static let lastUpdated = "lastUpdated"
        static let selectedState = "selectedState"
        static let isPerCapita = "isPerCapita"
        static let newCases = "newCases"
        static let top = "top"
        static let lastDays = "lastDays"
    }
}
