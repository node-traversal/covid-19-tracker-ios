//
//  CountryData.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/13/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

enum CountryData {
    static var current = CountryData.loadData()
    
    private static func loadData() -> CountyTimelineData {
        print("Loading county data from csv...")
        guard let asset = NSDataAsset(name: "USCensusData") else {
            fatalError("could not load county data")
        }
        let text = String(data: asset.data, encoding: .iso2022JP) ?? ""
        guard let data = CountyTimelineData(text: text.replacingOccurrences(of: "\r", with: "")) else {
            fatalError("could not process county data")
        }
        print("Loaded county data from csv")
        return data
    }
}
