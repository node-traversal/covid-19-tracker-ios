//
//  NewCasesViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import SwiftCharts

class NewCasesViewController: UIViewController {
    @IBOutlet private weak var chartView: XYChartView!
    
    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ChartTheme.labelFont)
        print("initializing chart data")
        var series: [DateSeries] = []
        var counties = Array(CountryData.current.countyDataPoints.keys)
        counties.sort()
        
        var yMax = 0
        for county in counties {
            var dataPoints: [(date: String, value: Int)] = []
            let data = CountryData.current.countyDataPoints[county]!
            for (index, value) in data.enumerated() {
                let date = CountryData.current.dates[index]
                yMax = max(yMax, value)
                dataPoints.append((date: date, value: value))
            }
            series.append(DateSeries(county, dataPoints))
        }
        
        chartView.dataModel = DateSeriesDataModel(series, yAxisTitle: "New Cases", yMax: yMax, labelSettings: labelSettings)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        chartView.updateChart()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_ : UIViewControllerTransitionCoordinatorContext) -> Void in
            let orientation = Env.orientation
            guard (self.lastOrientation.map { $0.rawValue != orientation.rawValue } ?? true) else { return }
            self.lastOrientation = orientation
            
            print("rotated")
            self.chartView.updateChart()
        }, completion: { (_ : UIViewControllerTransitionCoordinatorContext) -> Void in
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
}
