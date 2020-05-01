//
//  NewCasesViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import SwiftCharts
import ChartLegends
import Alamofire

protocol NumbericReader {
    func read(_ key: String, _ values: [Int], _ dates: [String], _ newCases: Bool) -> [(date: String, value: Any)]
    
    func getYMax() -> Any
}

class IntReader: NumbericReader {
    private var yMax: Int = 0
    
    func read(_ key: String, _ values: [Int], _ dates: [String], _ newCases: Bool) -> [(date: String, value: Any)] {
        var dataPoints: [(date: String, value: Int)] = []
        var lastValue: Int?
               
        for (index, rawValue) in values.enumerated() {
            var value: Int = rawValue

            if newCases {
                value = rawValue - (lastValue ?? rawValue)
            }

            let date = dates[index]
            self.yMax = max(self.yMax, value)
            
            if !newCases || lastValue != nil {
                dataPoints.append((date: date, value: value))
            }
            lastValue = rawValue
        }
        
        return dataPoints
    }
    
    func getYMax() -> Any {
        return yMax
    }
}

class DoubleReader: NumbericReader {
    private let population = CountryData.current.population
    private var yMax: Double = 0
        
    func read(_ key: String, _ values: [Int], _ dates: [String], _ newCases: Bool) -> [(date: String, value: Any)] {
        var dataPoints: [(date: String, value: Double)] = []
        
        let populationFactor = Double(population[key] ?? 0)

        if populationFactor == 0 {
            print("skipping \(key) - no population!")
            return []
        }
        print("  K:\(key) \(populationFactor)")

        var lastValue: Double?
        
        for (index, rawValue) in values.enumerated() {
            let rawDoubleValue = Double(rawValue) / populationFactor
            
            var value: Double = rawDoubleValue
            if newCases {
                value = rawDoubleValue - (lastValue ?? rawDoubleValue)
            }

            let date = dates[index]
            self.yMax = max(self.yMax, value)
            
            if !newCases || lastValue != nil {
                dataPoints.append((date: date, value: value))
            }
            
            lastValue = rawDoubleValue
        }
        
        return dataPoints
    }
    
    func getYMax() -> Any {
        return yMax
    }
}

class NewCasesViewController: UIViewController {
    @IBOutlet private weak var chartView: XYChartView?
    @IBOutlet private weak var legendsView: ChartLegendsView!
    @IBOutlet private weak var chartTitle: UILabel!
    @IBOutlet private weak var settingsButton: UIButton!
    
    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    private var rawData: ConfirmedCasesData?
    private var model: NewCases?
    private var chartSettings: CasesChartSettings = CasesChartSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        
        guard let chartView = chartView else { return }
        
        //settingsButton.tintColor = .label
        chartView.backgroundColor = view.backgroundColor
        legendsView.backgroundColor = view.backgroundColor
        chartTitle.text = "Loading New Cases ..."
        
        settingsButton.isEnabled = false
        
        print("initializing chart data")
        requestData()
    }
    
    // swiftlint:disable:next function_body_length
    private func processData(_ data: ConfirmedCasesData) {
        guard let chartView = chartView else { return }
        guard !data.dates.isEmpty else {
            print("Chart data received was empty!")
            return
        }
        
        var counties = Array(data.series)
        counties.sort {
            $0.lastValue! > $1.lastValue!
        }
        let dates = data.dates
        let model = NewCases()
        let stateFilter = chartSettings.selectedState
        
        model.series = []
        model.xCompact = self.traitCollection.horizontalSizeClass == .compact
        
        print("Processing chart data:")
        
        chartSettings.lastUpdated = dates.last ?? ""
        
        var legends = [(text: String, color: UIColor)]()

        let reader: NumbericReader = chartSettings.isPerCapita ? DoubleReader() : IntReader()
        
        var size = 0
        for countyData in counties {
            let county = countyData.county ?? ""
            let state = countyData.provinceState ?? "?"
            let key = "\(state), \(county)"
            
            if county.isEmpty || (!stateFilter.isEmpty && state != stateFilter) {
                //print("skipping \(key) - excluded key")
                continue
            }
            
            let settings = self.chartSettings
            var minPoint = 0
            var maxPoint = dates.count - 1
            if settings.limitDays != 0 {
                minPoint = settings.lastDays
                maxPoint = settings.lastDays + chartSettings.limitDays
            } else if settings.lastDays > 0 {
                minPoint = max(dates.count - chartSettings.lastDays, 0)
            }
            
            guard dates.count == countyData.values.count else {
                fatalError("\(key) found value count: \(countyData.values.count), expected \(dates.count)")
            }
            
            let dataPoints = reader.read(
                key,
                Array(countyData.values[minPoint...maxPoint]),
                Array(dates[minPoint...maxPoint]),
                chartSettings.isNewCases
            )
            if dataPoints.isEmpty {
                continue
            }
            
            print("  K:\(key) COLOR: \(size)")
            model.series.append(DateSeries(county, dataPoints))
            //  model.series.append(DateSeries(county, [dataPoints]))
            legends.append((text: county, ChartTheme.color(size)))
            size += 1
            if size >= chartSettings.top {
                break
            }
        }
        
        model.yMax = reader.getYMax()
        model.doubleFormatter = chartSettings.isNewCases ? NewCases.percentFormat(3) : NewCases.percentFormat(1)
        
        if model.series.isEmpty {
            print("No data!")
            return
        }
        
        self.model = model
        createModel(chartView)
        
        legendsView.setLegends(.circle(radius: 7.0), legends)
        
        setChartTitle()
        settingsButton.isEnabled = true
        
        rawData = data
    }
    
    private func setChartTitle() {
        let prefix = chartSettings.selectedState.isEmpty ? "US" : chartSettings.selectedState
        let chartTypeLabel = chartSettings.isNewCases ? "New Cases" : "Cases"
        let suffix = chartSettings.isPerCapita ? " Per Capita" : ""
        
        chartTitle.text = "\(prefix) \(chartTypeLabel) \(suffix) - Top \(chartSettings.top)"
    }
    
    private func requestData() {
        if let url = Environments.current.confirmedUSCasesUrl {
            AF.request(url).validate().responseString { response in
                if let json = response.value, let jsonData = json.data(using: .utf8) {
                    guard let chartView = self.chartView else { return }
                    
                    let decoder = JSONDecoder()
                    let cases = try! decoder.decode(ConfirmedCasesData.self, from: jsonData)
                    self.processData(cases)
                    
                    chartView.layoutChart()
                }
            }
        }
    }

    func createModel(_ chartView: XYChartView) {
        guard let model = self.model else { return }
        
        print("Creating chart model: ")
        model.xCompact = self.traitCollection.horizontalSizeClass == .compact
        
        chartView.dataModel = DateSeriesDataModel(
            model.series,
            yAxisTitle: "",
            yMax: model.yMax,
            xCompact: model.xCompact,
            dateFormat: model.dateFormat,
            doubleFormatter: model.doubleFormatter
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let chartView = chartView else { return }
        guard let model = self.model else { return }
        
        print("Layout New Cases")
        let newXCompact = self.traitCollection.horizontalSizeClass == .compact
        if newXCompact != model.xCompact {
            createModel(chartView)
        }
        
        chartView.updateChart()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_ : UIViewControllerTransitionCoordinatorContext) -> Void in
            let orientation = Env.orientation
            guard (self.lastOrientation.map { $0.rawValue != orientation.rawValue } ?? true) else { return }
            self.lastOrientation = orientation
            guard let chartView = self.chartView else { return }
            guard let model = self.model else { return }
            
            print("rotated")
            let newXCompact = self.traitCollection.horizontalSizeClass == .compact
            if newXCompact != model.xCompact {
                print("rotated")
                self.createModel(chartView)
            }
            chartView.updateChart()
        }, completion: { (_ : UIViewControllerTransitionCoordinatorContext) -> Void in
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard let chartView = chartView else { return }
        guard let model = self.model else { return }
        
        let newXCompact = self.traitCollection.horizontalSizeClass == .compact
        if newXCompact != model.xCompact {
            print("traits changed?")
            createModel(chartView)
            chartView.updateChart()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        
        switch identifier {
        case "Settings":
            guard let navController = segue.destination as? UINavigationController,
                let destination = navController.topViewController as? ChartSettingsViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            destination.settings = self.chartSettings
        default:
            print("Unexpected navigation: \(identifier)")
        }
    }
    
    @IBAction private func unwindForSettings(sender: UIStoryboardSegue) {
        if let sourceController = sender.source as? ChartSettingsViewController {
            chartSettings = sourceController.settings
            saveSettings()
            print("received settings \(chartSettings.isPerCapita)")
            if let rawData = self.rawData {
                guard let chartView = self.chartView else { return }
                
                processData(rawData)
                
                setChartTitle()
                chartView.updateChart()
            }
        }
    }
    
    private func saveSettings() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: chartSettings, requiringSecureCoding: false)
            try data.write(to: CasesChartSettings.ArchiveUrl)
            print("Setting saved.")
        } catch {
            print("Failed to save settings...")
        }
    }
    
    private func loadSettings() {
        chartSettings = CasesChartSettings()
        
        if let nsData = NSData(contentsOf: CasesChartSettings.ArchiveUrl) {
            do {
                let data = Data(referencing: nsData)

                if let loadedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? CasesChartSettings {
                    chartSettings = loadedData
                }
            } catch {
                print("Couldn't read settings.")
            }
        }
    }
}
