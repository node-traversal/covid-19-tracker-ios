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

class NewCasesViewController: UIViewController {
    @IBOutlet private weak var chartView: XYChartView?
    @IBOutlet private weak var legendsView: ChartLegendsView!
    @IBOutlet private weak var chartTitle: UILabel!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var chartType: UISegmentedControl!
    
    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    private var rawData: ConfirmedCasesData?
    private var model: NewCases?
    private var chartSettings: CasesChartSettings = CasesChartSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chartView = chartView else { return }
        settingsButton.tintColor = .label
        chartView.backgroundColor = view.backgroundColor
        legendsView.backgroundColor = view.backgroundColor
        chartTitle.text = "Loading New Cases ..."
        
        settingsButton.isEnabled = false
        chartType.isEnabled = false
        
        print("initializing chart data")
        requestData()
    }
    
    private func processData(_ data: ConfirmedCasesData) {
        guard let chartView = chartView else { return }
        guard !data.dates.isEmpty else {
            print("Chart data received was empty!")
            return
        }
        
        let counties = data.series
        let dates = data.dates
        let model = NewCases()
        model.yMax = 0
        model.series = []
        model.xCompact = self.traitCollection.horizontalSizeClass == .compact
        
        print("Processing chart data:")
        
        chartSettings.lastUpdated = dates.last ?? ""
        
        var legends = [(text: String, color: UIColor)]()
        let population = CountryData.current.population
        
        var size = 0
        
        let stateFilter = "New York"
        
        for (countyIndex, countyData) in counties.enumerated() {
            var dataPoints: [(date: String, value: Int)] = []
            let county = countyData.county ?? "?"
            let state = countyData.provinceState ?? "?"
            if state != stateFilter {
                continue
            }
            let key = "\(state), \(county)"
            let populationFactor = Double(population[key] ?? 0)
            var lastValue = 0
            
            if populationFactor == 0 {
                print("skipping \(key) - no population!")
                continue
            }
            
            print("  K:\(key) \(populationFactor)")

            for (index, rawValue) in countyData.values.enumerated() {
                let percentPop: Double = Double(rawValue) / populationFactor * 100.0
                if percentPop > 1 {
                    let amount = String(format: "%.3f", percentPop)
                    print("duh \(amount)")
                }
                var value = rawValue
                if chartSettings.newCases {
                    value = rawValue - lastValue
                }

                let date = dates[index]
                model.yMax = max(model.yMax, value)
                dataPoints.append((date: date, value: value))
                lastValue = rawValue
            }
            model.series.append(DateSeries(county, dataPoints))
            legends.append((text: county, ChartTheme.color(countyIndex)))
            size += 1
            if size >= 15 {
                break
            }
        }
        
        if model.series.isEmpty {
            print("No data!")
            return
        }
        
        self.model = model
        createModel(chartView)
        
        print("Creating legend...")
        legendsView.setLegends(.circle(radius: 7.0), legends)
        print("Created legend")
        
        let chartTypeLabel = chartSettings.newCases ? "New Cases" : "Cases"
        chartTitle.text = "US \(chartTypeLabel) - Top Ten Counties"
        settingsButton.isEnabled = true
        
        rawData = data
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
        chartView.dataModel = DateSeriesDataModel(model.series, yMax: model.yMax, xCompact: model.xCompact, dateFormat: model.dateFormat)
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
            print("received settings \(chartSettings.perCapita)")
            
            if let rawData = self.rawData {
                guard let chartView = self.chartView else { return }
                
                processData(rawData)
                
                chartView.updateChart()
            }
        }
    }
}
