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
    var dataPoints: [(date: String, value: Int)]
    
    init(_ name: String, _ dataPoints: [(date: String, value: Int)]) {
        self.name = name
        self.dataPoints = dataPoints
    }
}

private class DateSeriesChartFactory {
    let readFormatter: DateFormatter = DateFormatter()
    let displayFormatter: DateFormatter = DateFormatter()
    
    init(_ dateFormat: String = "MM.dd.yyyy") {
        readFormatter.dateFormat = dateFormat
        displayFormatter.dateFormat = "MM.dd"
    }
    
    func toDate(_ dateString: String) -> Date {
        return readFormatter.date(from: dateString) ?? Date()
    }
    
    private func createChartPoint(dateStr: String, value: Int) -> ChartPoint {
        return ChartPoint(x: createDateAxisDate(dateStr), y: ChartAxisValueInt(value))
    }
    
    func createDateAxisDateLabel(_ date: Date) -> ChartAxisValue {
        print("D:\(date)")
        let labelSettings = ChartTheme.labelSettings
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    func createDateAxisDateValue(_ date: Date) -> ChartAxisValue {
        let labelSettings = ChartTheme.labelSettings
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    func createDateAxisDate(_ dateStr: String) -> ChartAxisValue {
        return createDateAxisDateValue(readFormatter.date(from: dateStr)!)
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
    
    private func toChartPoints(_ dataPoints: [(date: String, value: Int)]) -> [ChartPoint] {
        var chartPoints = [ChartPoint]()
        
        for (date, value) in dataPoints {
            chartPoints.append(createChartPoint(dateStr: date, value: value))
        }
        
        return chartPoints
    }
}

class DateSeriesDataModel {
    var xAxisModel: ChartAxisModel
    var yAxisModel: ChartAxisModel
    var lines: [ChartLineModel<ChartPoint>]
        
    static func example() -> DateSeriesDataModel {
        return DateSeriesDataModel([DateSeries("Dallas", [
            ("10-01-2015", 5),
            ("10-04-2015", 10),
            ("10-05-2015", 30),
            ("10-06-2015", 70),
            ("10-08-2015", 79),
            ("10-10-2015", 90),
            ("10-12-2015", 47),
            ("10-14-2015", 60),
            ("10-15-2015", 70),
            ("10-16-2015", 80),
            ("10-19-2015", 90),
            ("10-21-2015", 100)
        ])], yAxisTitle: "Y-AXIS", yMax: 100, xCompact: false)
    }
    
    init(_ data: [DateSeries], yAxisTitle: String, yMax: Int, xCompact: Bool, dateFormat: String = "MM.dd.yyyy") {
        let factory: DateSeriesChartFactory = DateSeriesChartFactory(dateFormat)
        let begin = data.first!
        let xMin = factory.toDate(begin.dataPoints.first!.date)
        let xMax = factory.toDate(begin.dataPoints.last!.date)
        var xDensity: Double = 10
        if xCompact {
            print("using small density")
            xDensity = 5
        } else {
            print("using large density")
        }
        let xSpan: TimeInterval = max(floor(xMin.days(to: xMax) / xDensity), 1)
        let ySpan: Int = Int(max(floor(Double(yMax) / 10), 1))
        let yValues = stride(from: 0, through: yMax, by: ySpan).map { ChartAxisValueInt($0, labelSettings: ChartTheme.labelSettings) }
        // reversing the order ensures that the last date is should with its actual value, rather than the possibly being hidden in the stride span
        let xValues = stride(from: xMax, to: xMin, by: -Date.daysDurationInSeconds * xSpan).map { factory.createDateAxisDateLabel($0) }.reversed()
        self.lines = factory.toLines(data)
        self.xAxisModel = ChartAxisModel(axisValues: Array(xValues))
        self.yAxisModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: yAxisTitle, settings: ChartTheme.labelSettings.defaultVertical()))
    }
}
