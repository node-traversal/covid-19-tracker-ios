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

class NewCasesViewController: UIViewController {
    @IBOutlet private weak var chartView: XYChartView?
    @IBOutlet private weak var legendsView: ChartLegendsView!
    
    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    var series: [DateSeries] = []
    private var yMax = 0
    private var xCompact = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chartView = chartView else { return }
        chartView.backgroundColor = view.backgroundColor
        legendsView.backgroundColor = view.backgroundColor
        
        print("initializing chart data")
        var counties = Array(CountryData.current.countyDataPoints.keys)
        counties.sort()
        var legends = [(text: String, color: UIColor)]()
        
        for (index, county) in counties.enumerated() {
            var dataPoints: [(date: String, value: Int)] = []
            let data = CountryData.current.countyDataPoints[county]!
            for (index, value) in data.enumerated() {
                let date = CountryData.current.dates[index]
                yMax = max(yMax, value)
                dataPoints.append((date: date, value: value))
            }
            series.append(DateSeries(county, dataPoints))
            legends.append((text: county, ChartTheme.color(index)))
        }
        
        createModel(chartView)
        
        print("Creating legend...")
        legendsView.setLegends(.circle(radius: 7.0), legends)
        
        print("Createdlegend")
    }

    func createModel(_ chartView: XYChartView) {
        xCompact = self.traitCollection.horizontalSizeClass == .compact
        chartView.dataModel = DateSeriesDataModel(series, yAxisTitle: "New Cases", yMax: yMax, xCompact: xCompact)
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
