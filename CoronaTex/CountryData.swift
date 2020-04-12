//
//  CountryData.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/13/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class CountryData {
    
    static var current = CountryData.loadData()
    
    private static func loadData() -> CountyTimelineData {
        guard let asset = NSDataAsset(name: "Data") else {
            fatalError("could not load county data")
        }
        let text = String(data: asset.data, encoding: .iso2022JP) ?? ""
        guard let data = CountyTimelineData(text: text.replacingOccurrences(of: "\r", with: "")) else {
             fatalError("could not process county data")
         }
        
        return data
    }
}
