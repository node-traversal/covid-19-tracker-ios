//
//  NewCases.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/26/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation

class NewCases {
    var series: [DateSeries] = []
    var yMax: Any = 0
    var xCompact = false
    let dateFormat = "yyyy-MM-dd"
    var doubleFormatter: NumberFormatter = NewCases.percentFormat(2)
        
    static func percentFormat(_ digits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        
        return formatter
    }
}
