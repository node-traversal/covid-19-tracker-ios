//
//  CountryData.swift
//  EpiCenter
//
//  Created by Allen Parslow on 4/13/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import CoreLocation

struct Metros {
    var metroToCounties: [String: [String]] = [:]
}

struct MetroInfo {
    var location: NamedLocation
    fileprivate var county: String
    var state: String
    var population: Int
    fileprivate var largestCounty: Int
}

class CountyCensusData {
    let states: [String]
    private var populationByCounty: [String: Int] = [:]
    private var countyToMetro: [String: String] = [:]
    var majorMetros: [String: MetroInfo]
    
    static func isOtherCategoryKey(_ key: String) -> Bool {
        return key.contains("Unassigned") || key.contains("Out of") || key.contains("Correction")
    }
    
    func population(_ key: String) -> Int? {
        var population = populationByCounty[key]
        
        if population == nil && CountyCensusData.isOtherCategoryKey(key) {
            // give these unknowns a somewhat rural value
            population = 20000
        }
        
        return population
    }
        
    func metroName(_ key: String) -> String? {
        var metro = countyToMetro[key]
        
        if metro == nil && CountyCensusData.isOtherCategoryKey(key) {
            // give these unknowns a rural value
            metro = "Rural"
        }
        
        return metro
    }
    
    private static func validateHeader(_ index: Int, _ expected: String, _ headers: [Substring], _ headerIndexes: inout [Int]) -> Int {
        let header = headers[index]
        let valid = header == expected
        if !valid {
            assertionFailure("Expected header '\(expected)', found: '\(header)'")
        }
        headerIndexes.append(index)
        
        return index
    }
    
    init?(text: String) {
        var lines = text.split(separator: "\n")
        let headers = lines.removeFirst().split(separator: ",")
        var headerIndexes = [Int]()
        let stateIndex = CountyCensusData.validateHeader(0, "STATE", headers, &headerIndexes)
        let countyIndex = CountyCensusData.validateHeader(1, "COUNTY", headers, &headerIndexes)
        let populationIndex = CountyCensusData.validateHeader(3, "POPESTIMATE2019", headers, &headerIndexes)
        let metroNameIndex = CountyCensusData.validateHeader(2, "METRO_NAME", headers, &headerIndexes)
        let latitudeIndex = CountyCensusData.validateHeader(4, "LATITUDE", headers, &headerIndexes)
        let longitudeIndex = CountyCensusData.validateHeader(5, "LONGITUDE", headers, &headerIndexes)
        let metroPopulationIndex = CountyCensusData.validateHeader(6, "METRO_POPULATION", headers, &headerIndexes)
        
        let expectedMinHeaderCount = headerIndexes.max()!
        var statesMap = [String: Bool]()
        var metros = [String: MetroInfo]()
        
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
                let metroPopulation = Int(String(cells[metroPopulationIndex])) ?? 0
                let latitude = Double(String(cells[latitudeIndex])) ?? 0.0
                let longitude = Double(String(cells[longitudeIndex])) ?? 0.0
                
                populationByCounty[key] = populationValue
                countyToMetro[key] = metroName
                
                if metroPopulation > 1000000 && latitude != 0.0 && longitude != 0.0 {
                    var metro = MetroInfo(
                        location: NamedLocation(name: metroName, location: CLLocation(latitude: latitude, longitude: longitude)),
                        county: country,
                        state: state,
                        population: metroPopulation,
                        largestCounty: populationValue
                    )
                    if let previous = metros[metroName], previous.largestCounty > metro.largestCounty {
                        metro = previous
                    }
                       
                    metros[metroName] = metro
                }
                
                statesMap[state] = true
            }
        }
        states = Array(statesMap.keys.sorted())
        majorMetros = metros
    }
}

enum CountyData {
    static var current = CountyData.loadData()
    
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
