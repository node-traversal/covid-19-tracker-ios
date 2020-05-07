//
//  StatisticsSettings.swift
//  EpiCenter
//
//  Created by Allen Parslow on 5/4/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation

enum CountyGroupBy {
    case none
    case state
    case metro
    case metroFlat
}

enum CountySortBy {
    case population
    case newCases
    case totalCases
    case percent
    case label
}

class StatisticsSettings: LocationSettings {
    static let groupBySelections: [CountyGroupBy] = [.none, .state, .metro, .metroFlat]
    static let sortSelections: [CountySortBy] = [.percent, .newCases, .totalCases, .population, .label]
    
    var groupBy: CountyGroupBy = .none
    var sortBy: CountySortBy = .percent
    var prefix: String {
        "\(selectedState) "
    }
        
    override func getPersistentFolderName() -> String {
        return "StatisticsSettings"
    }
    
    func tableKey(county: String, state: String, metro: String) -> String {
        var tableKey = ""
        
        switch groupBy {
        case .none:
            if !selectedState.isEmpty {
                tableKey = county
            } else if sortBy == .label {
                tableKey = "\(state), \(county)"
            } else {
                tableKey = "\(county), \(state)"
            }
        case .state:
            tableKey = county
        case .metro:
            tableKey = county
        case .metroFlat:
            if !selectedState.isEmpty {
                tableKey = metro
            } else if sortBy == .label {
                tableKey = "\(state), \(metro)"
            } else {
                tableKey = "\(metro), \(state)"
            }
        }
        
        return tableKey
    }
    
    func grouping(county: String, state: String, metro: String) -> String {
        var group = ""
        
        switch groupBy {
        case .none:
            group = "\(prefix)Counties"
        case .state:
            group = state
        case .metro:
            group = "\(state), \(metro)"
        case .metroFlat:
            group = "\(prefix)Metro Areas"
        }
        
        return group
    }
    
    func sortKey(percent: Double, newCases: Int, totalCases: Int, population: Int) -> Double {
        var sortKey = 0.0
        
        switch sortBy {
        case .population:
            sortKey = Double(population)
        case .newCases:
            sortKey = Double(newCases)
        case .totalCases:
            sortKey = Double(totalCases)
        case .percent:
            sortKey = percent
        case .label:
            sortKey = 0.0
        }
        
        return sortKey
    }
    
    func isFiltered(key: String, state: String, county: String) -> Bool {
        if !selectedState.isEmpty {
            return state != selectedState
        } else {
            return false
        }
    }
    
    func detail(percent: String, newCases: Int, totalCases: Int, population: Int) -> String {
        return "\(percent) | New: \(String(newCases)) | Total: \(totalCases) | Pop: \(population)"
    }
}
