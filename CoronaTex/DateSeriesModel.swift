//
//  NewCases.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/26/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class NumericDateSeries<T: Numeric & Comparable>: Comparable {
    static func < (lhs: NumericDateSeries<T>, rhs: NumericDateSeries<T>) -> Bool {
        return lhs.yMax < rhs.yMax
    }
    
    static func == (lhs: NumericDateSeries<T>, rhs: NumericDateSeries<T>) -> Bool {
        return lhs.yMax == rhs.yMax
    }
    
    var key: String
    var name: String
    var dataPoints: [(date: String, value: T)]
    var yMax: T
    var lastValue: T
    var isEmpty: Bool {
        return dataPoints.isEmpty
    }
    
    init(_ key: String, _ name: String, _ yMax: T, _ dataPoints: [(date: String, value: T)]) {
        self.key = key
        self.name = name
        self.dataPoints = dataPoints
        self.yMax = yMax
        self.lastValue = !dataPoints.isEmpty ? dataPoints[dataPoints.count - 1].value : 0
    }
}

class FinalDateSeries {
    var key: String
    var name: String
    var dataPoints: [(date: String, value: Any)]
    var lastValue: Any
    var isEmpty: Bool {
        return dataPoints.isEmpty
    }
    
    init(_ key: String, _ name: String, _ dataPoints: [(date: String, value: Any)]) {
        self.key = key
        self.name = name
        self.dataPoints = dataPoints
        self.lastValue = !dataPoints.isEmpty ? dataPoints[dataPoints.count - 1].value : 0
    }
}

class DateSeriesModel {
    var series: [FinalDateSeries] = []
    var yAxisTitle = ""
    var yMax: Any = 0
    var xCompact = false
    let dateFormat = "yyyy-MM-dd"
    var doubleFormatter: NumberFormatter = NumberFormatter()
    var legends = [(text: String, color: UIColor)]()
}
