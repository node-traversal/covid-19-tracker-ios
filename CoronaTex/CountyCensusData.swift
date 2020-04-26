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
    
    private static func validateHeader(_ index: Int, _ expected: String, _ headers: [Substring]) -> Int {
        let header = headers[index]
        let valid = header == expected
        if !valid {
            print("Expected header '\(expected)', found: '\(header)'")
            return -1
        }
        
        return index
    }
    
    init?(text: String) {
        var lines = text.split(separator: "\n")
        let headers = lines.removeFirst().split(separator: ",")
        let stateIndex = CountyCensusData.validateHeader(0, "STATE", headers)
        let countyIndex = CountyCensusData.validateHeader(1, "COUNTY", headers)
        let populationIndex = CountyCensusData.validateHeader(3, "POPESTIMATE2019", headers)
        let expectedMinHeaderCount = max(countyIndex, populationIndex)
        
        guard (countyIndex >= 0) && (populationIndex >= 0) else {
            os_log("Invalid data headers", log: OSLog.default, type: .error)
            return nil
        }
        
        for line in lines {
            let cells = line.split(separator: ",")
              
            if cells.count > expectedMinHeaderCount {
                let state = String(cells[stateIndex])
                let country = String(cells[countyIndex])
                let key = "\(state), \(country)"
                let populationValue = Int(String(cells[populationIndex])) ?? 0

                population[key] = populationValue
            }
        }
    }
}
