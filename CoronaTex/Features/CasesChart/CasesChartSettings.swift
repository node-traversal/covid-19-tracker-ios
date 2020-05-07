//
//  CasesChartSettings.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/25/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class CasesChartSettings: LocationSettings {
    static let topSelections = [5, 10, 25]
    static let smoothingSelections = [0, 2, 4]
    static let daySelections = [[0, 0], [14, 0], [30, 0], [60, 0], [40, 30]]
    
    var lastUpdated: String = ""
    var isPerCapita: Bool = false
    var isNewCases: Bool = true
    var isMetroGrouped: Bool = true
    var top: Int = 5
    var smoothing: Int = 0
    var lastDays: Int = 0
    var limitDays: Int = 0
        
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        
        coder.encode(lastUpdated, forKey: PropertyKey.lastUpdated)
        coder.encode(isPerCapita, forKey: PropertyKey.isPerCapita)
        coder.encode(isNewCases, forKey: PropertyKey.isNewCases)
        coder.encode(isMetroGrouped, forKey: PropertyKey.isMetroGrouped)
        coder.encode(top, forKey: PropertyKey.top)
        coder.encode(smoothing, forKey: PropertyKey.smoothing)
        coder.encode(lastDays, forKey: PropertyKey.lastDays)
    }
    
    required init() { super.init() }
    
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
        self.init()
        super.decodeSettings(coder: coder)

        self.lastUpdated = lastUpdated
        self.isPerCapita = coder.decodeBool(forKey: PropertyKey.isPerCapita)
        self.isNewCases = coder.decodeBool(forKey: PropertyKey.isNewCases)
        self.isMetroGrouped = coder.decodeBool(forKey: PropertyKey.isMetroGrouped)
        self.top = coder.decodeInteger(forKey: PropertyKey.top)
        self.smoothing = coder.decodeInteger(forKey: PropertyKey.smoothing)
        self.lastDays = coder.decodeInteger(forKey: PropertyKey.lastDays)
    }
    
    static func findDayIndex(_ day: Int) -> Int {
        return CasesChartSettings.daySelections.firstIndex { $0[0] == day } ?? 0
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
        return CountyData.current.population(key) != nil
    }
    
    func isFiltered(key: String, state: String, county: String) -> Bool {
        if !selectedState.isEmpty {
            return state != selectedState
        } else {
            let metro = CountyData.current.metroName(key) ?? "Rural"
            return metro == "Rural"
        }
    }
    
    static func percentFormat(_ digits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        
        return formatter
    }
    
    override func getPersistentFolderName() -> String {
        return "CasesChartSettings"
    }
         
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
