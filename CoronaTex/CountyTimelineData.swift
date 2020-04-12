//
//  CountyTimelineData.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import os.log

class CountyTimelineData {
    
    var countyPopulation: [String: Int] = [:]
    var dates: [String] = []
    var countyDataPoints: [String: [Int]] = [:]
    
    private static func validateHeader(_ index: Int,  _ expected: String, _ headers: [Substring]) -> Int {
        let header = headers[index]
        let valid = header == expected
        if !valid {
            print("Expected data header '\(expected)', found: '\(header)'")
            return -1
        }
        
        return index
    }
    
    init?(text: String) {
        var lines = text.split(separator: "\n")
        let headers = lines.removeFirst().split(separator: ",")
        let countyIndex = CountyTimelineData.validateHeader(0, "County Name", headers)
        let populationIndex = CountyTimelineData.validateHeader(1, "Population", headers)
        guard (countyIndex >= 0) && (populationIndex >= 0) else {
            os_log("Invalid data headers", log: OSLog.default, type: .error)
            return nil
        }

        for (index, header) in headers.enumerated() {
            if (index > populationIndex) {
                if header.range(of: #"^\d\d-\d\d$"#, options: .regularExpression) == nil {
                    print("Invalid date cell \(header) @ header index: \(index)")
                    return nil
                }
                dates.append(String(header + "-2020"))
            }
        }
        
        for line in lines {
            let cells = line.split(separator: ",")
            var country = "?"
            var population = 0
            var data = [Int]()
            for (index, cell) in cells.enumerated() {
                if index == countyIndex {
                    country = String(cell)
                } else if index == populationIndex {
                    population = Int(String(cell)) ?? 0
                } else {
                    data.append(Int(String(cell)) ?? 0)
                }
            }
            countyDataPoints[country] = data
            countyPopulation[country] = population
        }
    }
}
