//
//  CountryData.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/13/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

struct Metros {
    var metroToCounties: [String: [String]] = [:]
}

class CountyCensusData {
    var population: [String: Int] = [:]
    var states: [String]
    private var countyToMetro: [String: String] = [:]
    
    func metroName(_ key: String) -> String {
        return countyToMetro[key] ?? "Rural"
    }
    
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
        let populationIndex = CountyCensusData.validateHeader(3, "POPESTIMATE2019", headers)
        let metroNameIndex = CountyCensusData.validateHeader(2, "METRO_NAME", headers)
        let expectedMinHeaderCount = max(stateIndex, countyIndex, populationIndex, metroNameIndex)
        var statesMap = [String: Bool]()
        
        guard (countyIndex >= 0) && (populationIndex >= 0) else {
            print("Invalid data headers")
            return nil
        }

        for line in lines {
            let cells = line.split(separator: ",")
              
            if cells.count > expectedMinHeaderCount {
                let state = String(cells[stateIndex])
                let country = String(cells[countyIndex])
                let metroName = String(cells[metroNameIndex])
                let key = "\(state), \(country)"
                let populationValue = Int(String(cells[populationIndex])) ?? 0

                population[key] = populationValue
                countyToMetro[key] = metroName
                
                statesMap[state] = true
            }
        }
        states = Array(statesMap.keys.sorted())
    }
}

enum CountryData {
    static var current = CountryData.loadData()
    
    private static func loadData() -> CountyCensusData {
        print("Loading county data from csv...")
        guard let asset = NSDataAsset(name: "USCensusData") else {
            fatalError("could not load county data")
        }
        let text = String(data: asset.data, encoding: .iso2022JP) ?? ""
        guard let data = CountyCensusData(text: text.replacingOccurrences(of: "\r", with: "")) else {
            fatalError("could not process county data")
        }
        print("Loaded county data from csv")
        return data
    }
}
