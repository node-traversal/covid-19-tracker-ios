//
//  ConfirmedCases.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/20/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

struct CountyCaseData: Codable {
    var county: String?
    var provinceState: String?
    var values: [Int]
    var lastValue: Int?
}

struct ConfirmedCasesData: Codable {
    var dates: [String]
    var series: [CountyCaseData]
}

enum ConfirmedCases {
    static var current = ConfirmedCases.loadData()
    
    private static func loadData() -> ConfirmedCasesData {
        print("Loading county data from json...")
        guard let asset = NSDataAsset(name: "ConfirmedUS") else {
            fatalError("could not load US data")
        }
        
        let decoder = JSONDecoder()
        print("Processing county data json...")
        let cases = try! decoder.decode(ConfirmedCasesData.self, from: asset.data)

        print("Loaded county data json.")
        return cases
    }
}
