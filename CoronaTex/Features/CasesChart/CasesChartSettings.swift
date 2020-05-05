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
    static let smoothingSelections = [0, 2, 4]
    static let daySelections = [[0, 0], [14, 0], [30, 0], [60, 0], [40, 30]]
    
    var lastUpdated: String = ""
    var selectedState: String = ""
    var isPerCapita: Bool = false
    var isNewCases: Bool = true
    var isMetroGrouped: Bool = true
    var top: Int = 5
    var smoothing: Int = 0
    var lastDays: Int = 0
    var limitDays: Int = 0
    
    static func findDayIndex(_ day: Int) -> Int {
        return CasesChartSettings.daySelections.firstIndex { $0[0] == day } ?? 0
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(lastUpdated, forKey: PropertyKey.lastUpdated)
        coder.encode(selectedState, forKey: PropertyKey.selectedState)
        coder.encode(isPerCapita, forKey: PropertyKey.isPerCapita)
        coder.encode(isNewCases, forKey: PropertyKey.isNewCases)
        coder.encode(isMetroGrouped, forKey: PropertyKey.isMetroGrouped)
        coder.encode(top, forKey: PropertyKey.top)
        coder.encode(smoothing, forKey: PropertyKey.smoothing)
        coder.encode(lastDays, forKey: PropertyKey.lastDays)
    }
    override init() { super.init() }
    
    convenience init(
        lastUpdated: String,
        selectedState: String,
        isPerCapita: Bool,
        isNewCases: Bool,
        isMetroGrouped: Bool,
        top: Int,
        smoothing: Int,
        lastDays: Int
    ) {
        self.init()
        self.lastUpdated = lastUpdated
        self.selectedState = selectedState
        self.isPerCapita = isPerCapita
        self.isNewCases = isNewCases
        self.isMetroGrouped = isMetroGrouped
        self.top = top
        self.smoothing = smoothing
        self.lastDays = lastDays
    }
    
    required convenience init?(coder: NSCoder) {
        guard let lastUpdated = coder.decodeObject(forKey: PropertyKey.lastUpdated) as? String else {
            print("No lastUpdated in presistent data...")
            return nil
        }
        let selectedState = coder.decodeObject(forKey: PropertyKey.selectedState) as? String ?? ""
        
        let isPerCapita = coder.decodeBool(forKey: PropertyKey.isPerCapita)
        let isNewCases = coder.decodeBool(forKey: PropertyKey.isNewCases)
        let isMetroGrouped = coder.decodeBool(forKey: PropertyKey.isMetroGrouped)
        let top = coder.decodeInteger(forKey: PropertyKey.top)
        let smoothing = coder.decodeInteger(forKey: PropertyKey.smoothing)
        let lastDays = coder.decodeInteger(forKey: PropertyKey.lastDays)
        
        self.init(
            lastUpdated: lastUpdated,
            selectedState: selectedState,
            isPerCapita: isPerCapita,
            isNewCases: isNewCases,
            isMetroGrouped: isMetroGrouped,
            top: top,
            smoothing: smoothing,
            lastDays: lastDays
        )
    }
    
    func dateRange(_ dateCount: Int) -> (min: Int, max: Int) {
        var minPoint = 0
        var maxPoint = dateCount - 1
        if self.limitDays != 0 {
            minPoint = self.lastDays
            maxPoint = self.lastDays + self.limitDays
        } else if self.lastDays > 0 {
            minPoint = max(dateCount - self.lastDays, 0)
        }
        
        return (min: minPoint, max: maxPoint)
    }
    
    func getDoubleFormatter() -> NumberFormatter {
        return isNewCases ? CasesChartSettings.percentFormat(3) : CasesChartSettings.percentFormat(1)
    }
    
    static func isValid(_ key: String) -> Bool {
        return CountryData.current.population(key) != nil
    }
    
    func isFiltered(key: String, state: String, county: String) -> Bool {
        if !selectedState.isEmpty {
            return state != selectedState
        } else {
            let metro = CountryData.current.metroName(key) ?? "Rural"
            return metro == "Rural"
        }
    }
       
    func save() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try data.write(to: CasesChartSettings.ArchiveUrl)
            print("Setting saved.")
        } catch {
            print("Failed to save settings...")
        }
    }
    
    static func load() -> CasesChartSettings {
        var chartSettings = CasesChartSettings()
        
        if let nsData = NSData(contentsOf: CasesChartSettings.ArchiveUrl) {
            do {
                let data = Data(referencing: nsData)

                if let loadedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? CasesChartSettings {
                    chartSettings = loadedData
                }
            } catch {
                print("Couldn't read settings.")
            }
        }
        
        return chartSettings
    }
    
    static func percentFormat(_ digits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        
        return formatter
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private static let ArchiveUrl = getDocumentsDirectory().appendingPathComponent("CasesChartSettings")
    
    fileprivate enum PropertyKey {
        static let lastUpdated = "lastUpdated"
        static let selectedState = "selectedState"
        static let isPerCapita = "isPerCapita"
        static let isNewCases = "isNewCases"
        static let isMetroGrouped = "isMetroGrouped"
        static let top = "top"
        static let smoothing = "smoothing"
        static let lastDays = "lastDays"
    }
}
