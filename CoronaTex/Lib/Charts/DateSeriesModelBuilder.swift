//
//  DateSeriesModelBuilder.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/1/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import Foundation

private class DataSeriesInfo<Y> {
    let datapoints: [(date: String, value: Y)]
    let yMax: Y
    
    init(_ datapoints: [(date: String, value: Y)], _ yMax: Y) {
        self.datapoints = datapoints
        self.yMax = yMax
    }
}

class DoubleValueContext: ValueContext<Double> {
    init(_ transform: @escaping (String, Int) -> Double?) {
        func identity(_ value: Double) -> Double { return value }
        
        super.init(transform, toDouble: identity, toValue: identity)
    }
}

class IntValueContext: ValueContext<Int> {
    init() {
        func identity(_ key: String, _ value: Int) -> Int? { return value }
        func toDouble(_ value: Int) -> Double { return Double(value) }
        func toValue(_ value: Double) -> Int { return Int(round(value)) }
        
        super.init(identity, toDouble: toDouble, toValue: toValue)
    }
}

class ValueContext<Y: Numeric & Comparable> {
    var data = [String: NumericDateSeries<Y>]()
    var transform: (String, Int) -> Y?
    var toDouble: (Y) -> Double
    var toValue: (Double) -> Y
    
    init(_ transform: @escaping (String, Int) -> Y?, toDouble: @escaping (Y) -> Double, toValue: @escaping (Double) -> Y) {
        self.transform = transform
        self.toDouble = toDouble
        self.toValue = toValue
    }
    
    private func add(_ first: [(date: String, value: Y)], second secondOptional: [(date: String, value: Y)]?) -> DataSeriesInfo<Y> {
        var out = [(date: String, value: Y)]()
        var yMax: Y = 0
        
        for (index, pair) in first.enumerated() {
            var finalValue = pair.value

            if let secondValue = secondOptional {
                finalValue += secondValue[index].value
            }
            yMax = max(yMax, finalValue)

            out.append((date: pair.date, finalValue))
        }

        return DataSeriesInfo(out, yMax)
    }
    
    func toMetroArea() {
        var finalData = [String: NumericDateSeries<Y>]()

        for series in data.values {
            if let seriesName = CountyData.current.metroName(series.key) {
                let prevSeries = finalData[seriesName]
                let values = add(series.dataPoints, second: prevSeries?.dataPoints)
                finalData[seriesName] = NumericDateSeries<Y>(seriesName, seriesName, values.yMax, values.datapoints)
            }
        }
        
        data = finalData
    }
}

class SeriesStop<Y: Numeric & Comparable> {
    var context: ValueContext<Y>
    let settings: CasesChartSettings
    
    init(context: ValueContext<Y>, settings: CasesChartSettings) {
        self.context = context
        self.settings = settings
    }
        
    func postProcess(transform: () -> Void) -> SeriesStop<Y> {
        transform()
        
        return self
    }
    
    func build() -> DateSeriesModel {
        let model = DateSeriesModel()
        var size = 0

        var yMax: Y = 0
        for series in Array(context.data.values.sorted(by: >)) {
            print("  K:\(series.key) \(series.yMax) COLOR: \(size)")
            model.series.append(FinalDateSeries(series.key, series.name, series.dataPoints))
            model.legends.append((text: series.name, ChartTheme.color(size)))
            yMax = max(yMax, series.yMax)
            size += 1
            if size >= settings.top {
                break
            }
        }

        model.yMax = yMax
        model.doubleFormatter = settings.getDoubleFormatter()

        return model
    }
}

class LimitQueue<Y: Numeric & Comparable>: CustomStringConvertible {
    private let maxSize: Int
    private let context: ValueContext<Y>
    private var items = [Y]()
    
    var last: Y? {
        return items.last
    }
    
    var isComplete: Bool {
        return items.count == maxSize
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var description: String { return "\(items)" }
    
    init(maxSize: Int, context: ValueContext<Y>) {
        self.maxSize = maxSize
        self.context = context
    }

    func average(_ value: Y) -> Y {
        var sum: Y = 0
        
        for item in items {
            sum += item
        }
        
        sum += value
        
        return context.toValue(context.toDouble(sum) / Double((items.count + 1)))
    }
    
    func append(_ value: Y) {
        items.append(value)
        if items.count > maxSize {
            items.remove(at: 0)
        }
    }
}

class DateSeriesModelBuilder {
    private let settings: CasesChartSettings
    
    init(_ settings: CasesChartSettings) {
        self.settings = settings
    }
    
    static func convert(_ data: ConfirmedCasesData, _ settings: CasesChartSettings) -> DateSeriesModel {
        func noop() {}
        
        if settings.isPerCapita {
            func perCapita(_ key: String, _ value: Int) -> Double? {
                if let population = CountyData.current.population(key) {
                    return Double(value) / Double(population)
                } else {
                    return Optional.none
                }
            }
            let context = DoubleValueContext(perCapita)
            
            return DateSeriesModelBuilder(settings)
                .from(data, context)
                .postProcess(transform: settings.isMetroGrouped ? context.toMetroArea : noop)
                .build()
        } else {
            let context = IntValueContext()

            return DateSeriesModelBuilder(settings)
                .from(data, context)
                .postProcess(transform: settings.isMetroGrouped ? context.toMetroArea : noop)
                .build()
        }
    }
    
    func from<Y: Numeric>(_ data: ConfirmedCasesData, _ context: ValueContext<Y>) -> SeriesStop<Y> {
        let stop = SeriesStop<Y>(context: context, settings: settings)
        
        for countyData in data.series {
            let county = countyData.county ?? ""
            let state = countyData.provinceState ?? ""
            let key = "\(state), \(county)"
            let dates = data.dates
            
            if state.isEmpty || county.isEmpty {
                continue
            }
            
            if !CasesChartSettings.isValid(key) {
                print("\(key) is unknown, cases: \(countyData.lastValue ?? 0)")
                continue
            }
            
            if settings.isFiltered(key: key, state: state, county: county) {
                continue
            }
                    
            guard dates.count == countyData.values.count else {
                fatalError("\(key) found value count: \(countyData.values.count), expected \(dates.count)")
            }
            let dateRange = settings.dateRange(dates.count)
            let values = read(
                key,
                Array(countyData.values[dateRange.min...dateRange.max]),
                Array(dates[dateRange.min...dateRange.max]),
                context
            )

            let series = NumericDateSeries<Y>(
                key,
                county,
                values.yMax,
                values.datapoints
            )
            
            if series.isEmpty {
                continue
            }
            
            context.data[series.key] = series
        }
        
        return stop
    }
    
    private func read<Y: Numeric & Comparable>(_ key: String, _ values: [Int], _ dates: [String], _ context: ValueContext<Y>) -> DataSeriesInfo<Y> {
        var dataPoints: [(date: String, value: Y)] = []
        let lastValues = LimitQueue<Y>(maxSize: settings.smoothing, context: context)
        
        var yMax: Y = 0
        var lastValueOptional: Y?
        for (index, rawValue) in values.enumerated() {
            if let convertedValue: Y = context.transform(key, rawValue) {
                var isShouldAppend = true
                var value = convertedValue
                let date = dates[index]
                
                if settings.isNewCases {
                    if let lastValue = lastValueOptional {
                        value = convertedValue - lastValue
                    } else {
                        isShouldAppend = false
                    }
                }
                
                if settings.smoothing > 0 {
                    if lastValues.isComplete {
                        value = lastValues.average(value)
                    } else {
                        isShouldAppend = false
                    }
                }
                    
                if isShouldAppend {
                    dataPoints.append((date: date, value: value))
                    yMax = max(yMax, value)
                }
                
                if settings.smoothing > 0 {
                    lastValues.append(value)
                }
                lastValueOptional = convertedValue
            }
        }
        
        return DataSeriesInfo(dataPoints, yMax)
    }
}
