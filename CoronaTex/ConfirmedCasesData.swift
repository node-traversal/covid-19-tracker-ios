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

class ConfirmedCasesData: Codable {
    var dates: [String]
    var series: [CountyCaseData]
}
