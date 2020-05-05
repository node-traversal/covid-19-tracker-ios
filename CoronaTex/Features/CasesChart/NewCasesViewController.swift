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
    
    private var lastOrientation: UIInterfaceOrientation?
    private var rawData: ConfirmedCasesData?
    private var chartModel: DateSeriesModel?
    private var chartSettings: CasesChartSettings = CasesChartSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartSettings = CasesChartSettings.load()
        
        guard let chartView = chartView else { return }
        
        //settingsButton.tintColor = .label
        chartView.backgroundColor = view.backgroundColor
        legendsView.backgroundColor = view.backgroundColor
        chartTitle.text = "Loading New Cases ..."
        
        settingsButton.isEnabled = false
        
        print("initializing chart data")
        requestData()
    }
        
    private func processData(_ data: ConfirmedCasesData) {
        guard let chartView = chartView else { return }
        guard !data.dates.isEmpty else {
            print("Chart data received was empty!")
            return
        }
             
        print("Processing chart data:")
        let model = DateSeriesModelBuilder.convert(
            data,
            chartSettings
        )
            
        model.xCompact = self.traitCollection.horizontalSizeClass == .compact
        
        if model.series.isEmpty {
            print("No data!")
            return
        }
        
        rawData = data
        self.chartModel = model
        createModel(chartView)
        
        legendsView.setLegends(.circle(radius: 7.0), model.legends)
        
        chartSettings.lastUpdated = data.dates.last ?? ""
        setChartTitle()
        settingsButton.isEnabled = true
    }
    
    private func setChartTitle() {
        let prefix = chartSettings.selectedState.isEmpty ? "US" : chartSettings.selectedState
        let chartTypeLabel = chartSettings.isNewCases ? "New Cases" : "Cases"
        let suffix = chartSettings.isPerCapita ? " Per Capita" : ""
        let smoothing = chartSettings.smoothing > 0 ? " [Smoothed]" : ""
        chartTitle.text = "\(prefix) \(chartTypeLabel) \(suffix) - Top \(chartSettings.top) \(smoothing)"
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
        guard let model = self.chartModel else { return }
        
        print("Creating chart model: ")
        model.xCompact = self.traitCollection.horizontalSizeClass == .compact
        
        chartView.dataModel = DateSeriesChartModel(model)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let chartView = chartView else { return }
        guard let model = self.chartModel else { return }
        
        print("Layout New Cases")
        let newXCompact = self.traitCollection.horizontalSizeClass == .compact
        if newXCompact != model.xCompact {
            createModel(chartView)
        }
        
        chartView.updateChart()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_ : UIViewControllerTransitionCoordinatorContext) -> Void in
            let orientation = DeviceEnv.orientation
            guard (self.lastOrientation.map { $0.rawValue != orientation.rawValue } ?? true) else { return }
            self.lastOrientation = orientation
            guard let chartView = self.chartView else { return }
            guard let model = self.chartModel else { return }
            
            let newXCompact = self.traitCollection.horizontalSizeClass == .compact
            if newXCompact != model.xCompact {
                print("Screen rotated")
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
        guard let model = self.chartModel else { return }
        
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
            chartSettings.save()
            print("Received settings")
            
            // reprocess the raw data using the new settings
            if let rawData = self.rawData {
                guard let chartView = self.chartView else { return }
                
                processData(rawData)
                
                setChartTitle()
                chartView.updateChart()
            }
        }
    }
}
