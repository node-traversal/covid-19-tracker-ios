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
    
    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    var series: [DateSeries] = []
    private var yMax = 0
    private var xCompact = false
    private let dateFormat = "yyyy-MM-dd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chartView = chartView else { return }
        chartView.backgroundColor = view.backgroundColor
        legendsView.backgroundColor = view.backgroundColor
        chartTitle.text = "US New Cases - Top Ten Counties"
        
        print("initializing chart data")
        processData(ConfirmedCases.current)
        requestData()
    }
    
    private func processData(_ data: ConfirmedCasesData) {
        guard let chartView = chartView else { return }
        
        let counties = data.series
        let dates = data.dates
        let lastDate = dates.last ?? ""
        yMax = 0
        series = []
        
        print("Processing chart: \(lastDate)")
        var legends = [(text: String, color: UIColor)]()
        
        for (countyIndex, countyData) in counties.enumerated() {
            if (countyIndex) >= 15 {
                break
            }
            var dataPoints: [(date: String, value: Int)] = []
            let county = countyData.county ?? "?"
            print("C:\(county)")
            for (index, value) in countyData.values.enumerated() {
                let date = dates[index]
                yMax = max(yMax, value)
                dataPoints.append((date: date, value: value))
            }
            series.append(DateSeries(county, dataPoints))
            legends.append((text: county, ChartTheme.color(countyIndex)))
        }
        
        createModel(chartView)
        
        print("Creating legend...")
        legendsView.setLegends(.circle(radius: 7.0), legends)
        print("Createdlegend")
    }
    
    private func requestData() {
        if let url = Environments.current.confirmedUSCasesUrl {
            AF.request(url).validate().responseString { response in
                if let json = response.value, let jsonData = json.data(using: .utf8) {
                    guard let chartView = self.chartView else { return }
                    
                    let decoder = JSONDecoder()
                    let cases = try! decoder.decode(ConfirmedCasesData.self, from: jsonData)
                    self.processData(cases)
                    
                    chartView.updateChart()
                }
            }
        }
    }

    func createModel(_ chartView: XYChartView) {
        xCompact = self.traitCollection.horizontalSizeClass == .compact
        chartView.dataModel = DateSeriesDataModel(series, yAxisTitle: "New Cases", yMax: yMax, xCompact: xCompact, dateFormat: dateFormat)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let chartView = chartView else { return }
        print("layout subviews")
        let newXCompact = self.traitCollection.horizontalSizeClass == .compact
        if newXCompact != self.xCompact {
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
            
            print("rotated")
            let newXCompact = self.traitCollection.horizontalSizeClass == .compact
            if newXCompact != self.xCompact {
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
        let newXCompact = self.traitCollection.horizontalSizeClass == .compact
        if newXCompact != self.xCompact {
            print("traits changed?")
            createModel(chartView)
            chartView.updateChart()
        }
    }
}
