//
//  XYChartView.swift
//  EpiCenter
//
//  Created by Allen Parslow on 4/13/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import SwiftCharts

@IBDesignable
class XYChartView: UIView {
    fileprivate var chart: Chart?
    var dataModel: DateSeriesChartModel?
    
    private var didLayout: Bool = false
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init frame: \(frame.width)x\(frame.height)")
        layoutChart()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        layoutChart()
    }
    
    func layoutChart() {
        guard dataModel != nil else {
            print("No chart data yet ...")
            return
        }
        
        if !self.didLayout {
            print("layout chart: \(frame.width)x\(frame.height)")
            self.didLayout = true
            self.initChart()
        }
    }
    
    private func initChart() {
        print("Initializing chart: ")
        guard let dataModel = self.dataModel else { return }
        
        let chartFrame = ChartTheme.chartFrame(self.bounds)
        let chartSettings = ChartTheme.chartSettings
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: dataModel.xAxisModel, yModel: dataModel.yAxisModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)

        // delayInit parameter is needed by some layers for initial zoom level to work correctly. Setting it to true allows to trigger drawing of layer manually (in this case, after the chart is initialized). This obviously needs improvement. For now it's necessary.
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: dataModel.lines, delayInit: true)
        
        let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.label, linesWidth: 0.3)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer]
        )
        
        self.addSubview(chart.view)
        
        chartPointsLineLayer.initScreenLines(chart)
        
        self.addSubview(chart.view)

        self.chart = chart
    }
    
    func updateChart() {
        guard let theChart = self.chart else { return }
        
        for chartView in theChart.view.subviews {
            chartView.removeFromSuperview()
        }
        initChart()
        theChart.view.setNeedsDisplay()
    }
}
