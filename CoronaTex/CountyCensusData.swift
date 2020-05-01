//
//  CountyTimelineData.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import os.log

class CountyCensusData {
    var population: [String: Int] = [:]
    var states: [String]
    var countyToMetro: [String: String] = [:]
    var metroCounties: [String: [String]] = [:]
    
    private static func validateHeader(_ index: Int, _ expected: String, _ headers: [Substring]) -> Int {
        let header = headers[index]
        let valid = header == expected
        if !valid {
            assertionFailure("Expected header '\(expected)', found: '\(header)'")
        }
        
        return index
    }
    
    init?(text: String) {
        var lines = text.split(separator: "\n")
        let headers = lines.removeFirst().split(separator: ",")
        let stateIndex = CountyCensusData.validateHeader(0, "STATE", headers)
        let countyIndex = CountyCensusData.validateHeader(1, "COUNTY", headers)
        let populationIndex = CountyCensusData.validateHeader(2, "POPESTIMATE2019", headers)
        let metroNameIndex = CountyCensusData.validateHeader(3, "METRO_NAME", headers)
        let expectedMinHeaderCount = max(countyIndex, metroNameIndex)
        var statesMap = [String: Bool]()
        
        guard (countyIndex >= 0) && (populationIndex >= 0) else {
            os_log("Invalid data headers", log: OSLog.default, type: .error)
            return nil
        }
        
        for line in lines {
            let cells = line.split(separator: ",")
              
            if cells.count > expectedMinHeaderCount {
                let state = String(cells[stateIndex])
                let country = String(cells[countyIndex])
                let metro = String(cells[metroNameIndex])
                let key = "\(state), \(country)"
                let populationValue = Int(String(cells[populationIndex])) ?? 0

                population[key] = populationValue

                statesMap[state] = true
                
                var metroCountyArray = metroCounties[metro] ?? []
                metroCountyArray.append(key)
                metroCounties[metro] = metroCountyArray
            }
        }
        states = Array(statesMap.keys.sorted())
    }
}
