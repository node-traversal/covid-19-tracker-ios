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
    
    init() {
        readFormatter.dateFormat = "MM.dd.yyyy"
        displayFormatter.dateFormat = "MM.dd"
    }
    
    func toDate(_ dateString: String) -> Date {
        return readFormatter.date(from: dateString) ?? Date()
    }
    
    private func createChartPoint(dateStr: String, value: Int) -> ChartPoint {
        return ChartPoint(x: createDateAxisDate(dateStr), y: ChartAxisValueInt(value))
    }
    func createDateAxisDateValue(_ date: Date) -> ChartAxisValue {
        //let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, rotation: 45, rotationKeep: .top)
        let labelSettings = ChartLabelSettings(font: ChartTheme.labelFont)
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    func createDateAxisDate(_ dateStr: String) -> ChartAxisValue {
        return createDateAxisDateValue(readFormatter.date(from: dateStr)!)
    }
    
    func toLines(_ data: [DateSeries]) -> [ChartLineModel<ChartPoint>] {
        var lines = [ChartLineModel]()
        
        for series in data {
            let points = toChartPoints(series.dataPoints)
            lines.append(ChartLineModel(chartPoints: points, lineColor: UIColor.red, lineWidth: 2, animDuration: 1, animDelay: 0))
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
        let labelSettings = ChartLabelSettings(font: ChartTheme.labelFont)

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
        ])], yAxisTitle: "Y-AXIS", yMax: 100, labelSettings: labelSettings)
    }
    
    init(_ data: [DateSeries], yAxisTitle: String, yMax: Int, labelSettings: ChartLabelSettings) {
        let factory = DateSeriesChartFactory()
        
        let begin = data.first!
        let xMin = factory.toDate(begin.dataPoints.first!.date)
        let xMax = factory.toDate(begin.dataPoints.last!.date)
        let density: Double = 10
        let xSpan: TimeInterval = max(floor(xMin.days(to: xMax) / density), 1)
        let ySpan: Int = Int(max(floor(Double(yMax) / density), 1))
        let yValues = stride(from: 0, through: yMax, by: ySpan).map { ChartAxisValueInt($0, labelSettings: labelSettings) }
        let xValues = stride(from: xMin, to: xMax, by: Date.daysDurationInSeconds * xSpan).map { factory.createDateAxisDateValue($0) }
        self.lines = factory.toLines(data)
        self.xAxisModel = ChartAxisModel(axisValues: xValues)
        self.yAxisModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: yAxisTitle, settings: labelSettings.defaultVertical()))
    }
}
