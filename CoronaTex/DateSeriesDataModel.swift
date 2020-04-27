//
//  DateSeriesDataModel.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/13/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation
import SwiftCharts

class DateSeries {
    var name: String
    var dataPoints: [(date: String, value: Any)]
    
    init(_ name: String, _ dataPoints: [(date: String, value: Any)]) {
        self.name = name
        self.dataPoints = dataPoints
    }
}

private class DateSeriesChartFactory {
    let readFormatter: DateFormatter = DateFormatter()
    let displayFormatter: DateFormatter = DateFormatter()
    let doubleFormatter: NumberFormatter
    
    init(_ dateFormat: String = "MM.dd.yyyy", _ doubleFormatter: NumberFormatter = NumberFormatter()) {
        readFormatter.dateFormat = dateFormat
        displayFormatter.dateFormat = "MM.dd"
        self.doubleFormatter = doubleFormatter
    }
    
    func toDate(_ dateString: String) -> Date {
        return readFormatter.date(from: dateString) ?? Date()
    }
    
    private func createChartPoint(dateStr: String, value: Double) -> ChartPoint {
        return ChartPoint(x: createDateAxisDate(dateStr), y: ChartAxisValueDouble(value))
    }
    
    private func createChartPoint(dateStr: String, value: Int) -> ChartPoint {
        return ChartPoint(x: createDateAxisDate(dateStr), y: ChartAxisValueInt(value))
    }
    
    func createDateAxisDateLabel(_ date: Date) -> ChartAxisValue {
        print("  D:\(date)")
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: ChartTheme.labelSettings)
    }
        
    func createDateAxisDate(_ dateStr: String) -> ChartAxisValue {
        ChartAxisValueDate(date: readFormatter.date(from: dateStr)!, formatter: displayFormatter, labelSettings: ChartTheme.labelSettings)
    }
    
    func toLines(_ data: [DateSeries]) -> [ChartLineModel<ChartPoint>] {
        var lines = [ChartLineModel]()
        
        for (index, series) in data.enumerated() {
            let points = toChartPoints(series.dataPoints)
            let color = ChartTheme.color(index)
            lines.append(ChartLineModel(chartPoints: points, lineColor: color, lineWidth: 2, animDuration: 1, animDelay: 0))
        }
        
        return lines
    }
    
    func createNumericAxis(_ value: Any) -> [ChartAxisValue] {
        let valuetype = type(of: value)
        var axis: [ChartAxisValue]
        let maxPoints = 10
        
        if valuetype == Double.self, let yMax = value as? Double {
            let ySpan: Double = yMax / Double(maxPoints)
            axis = stride(from: 0, through: yMax, by: ySpan).map { ChartAxisValueDouble($0, formatter: doubleFormatter, labelSettings: ChartTheme.labelSettings) }
        } else if valuetype == Int.self, let yMax = value as? Int {
            let ySpan: Int = Int(max(floor(Double(yMax) / Double(maxPoints)), 1))
            axis = stride(from: 0, through: yMax, by: ySpan).map { ChartAxisValueInt($0, labelSettings: ChartTheme.labelSettings) }
        } else {
            fatalError("  Unknown value type: \(valuetype): \(value)")
        }
        
        if axis.isEmpty {
            fatalError("Axis was empty")
        }
        
        if axis.count > maxPoints + 1 {
            fatalError("Axis has too many datapoints, expected: \(maxPoints), found: \(axis.count)")
        }
        
        return axis
    }
    
    private func toChartPoints(_ dataPoints: [(date: String, value: Any)]) -> [ChartPoint] {
        var chartPoints = [ChartPoint]()
        
        for (date, value) in dataPoints {
            let valuetype = type(of: value)
            if valuetype == Double.self, let doubleValue = value as? Double {
                chartPoints.append(createChartPoint(dateStr: date, value: doubleValue))
            } else if valuetype == Int.self, let intValue = value as? Int {
                chartPoints.append(createChartPoint(dateStr: date, value: intValue))
            } else {
                print("  Unknown value type: \(valuetype): \(value)")
            }
        }
        
        if chartPoints.isEmpty {
            fatalError("No datapoints created!")
        }
        
        return chartPoints
    }
}

class DateSeriesDataModel {
    var xAxisModel: ChartAxisModel
    var yAxisModel: ChartAxisModel
    var lines: [ChartLineModel<ChartPoint>]
           
    init(_ data: [DateSeries], yAxisTitle: String, yMax: Any, xCompact: Bool, dateFormat: String, doubleFormatter: NumberFormatter) {
        let factory: DateSeriesChartFactory = DateSeriesChartFactory(dateFormat, doubleFormatter)
        let begin = data.first!
        let xMin = factory.toDate(begin.dataPoints.first!.date)
        let xMax = factory.toDate(begin.dataPoints.last!.date)
        var xDensity: Double = 10
        if xCompact {
            print("  using small density")
            xDensity = 5
        } else {
            print("  using large density")
        }
        let xSpan: TimeInterval = max(floor(xMin.days(to: xMax) / xDensity), 1)
        let yValues = factory.createNumericAxis(yMax)
        // reversing the order ensures that the last date is should with its actual value, rather than the possibly being hidden in the stride span
        let xValues = stride(from: xMax, to: xMin, by: -Date.daysDurationInSeconds * xSpan).map { factory.createDateAxisDateLabel($0) }.reversed()
        self.lines = factory.toLines(data)
        self.xAxisModel = ChartAxisModel(axisValues: Array(xValues), trailingPadding: .labelPlus(-10))
        var yAxisLabels = [ChartAxisLabel]()
        
        if !yAxisTitle.isEmpty {
            yAxisLabels.append(ChartAxisLabel(text: yAxisTitle, settings: ChartTheme.labelSettings.defaultVertical()))
        }
 
        self.yAxisModel = ChartAxisModel(axisValues: yValues, axisTitleLabels: yAxisLabels, trailingPadding: .label)
    }
}
