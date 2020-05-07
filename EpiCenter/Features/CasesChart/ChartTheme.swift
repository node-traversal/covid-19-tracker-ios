//
//  ChartTheme.swift
//  EpiCenter
//
//  Modified by Allen Parslow on 4/12/20.
//
//  Derived from:
//  ExamplesDefaults.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

enum ChartTheme {
    static let colors: [UIColor] = [.systemBlue, .systemPink, .systemGreen, .systemOrange, .systemPurple, .systemTeal, .systemRed, .systemYellow, .systemIndigo, .systemGray, .systemPink]
    
    static func color(_ index: Int) -> UIColor {
        return ChartTheme.colors[index % ChartTheme.colors.count]
    }
    
    static var chartSettings: ChartSettings {
        if DeviceEnv.iPad {
            return iPadChartSettings
        } else {
            return iPhoneChartSettings
        }
    }
    
    fileprivate static var iPadChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 20
        chartSettings.top = 20
        chartSettings.trailing = 20
        chartSettings.bottom = 20
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.labelsToAxisSpacingY = 10
        chartSettings.axisTitleLabelsToLabelsSpacing = 5
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 15
        chartSettings.spacingBetweenAxesY = 15
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    fileprivate static var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    static func chartFrame(_ containerBounds: CGRect) -> CGRect {
        print("\(containerBounds.size.width)x\(containerBounds.size.height)")
        return CGRect(x: 0, y: 0, width: containerBounds.size.width, height: containerBounds.size.height)
    }
    
    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: ChartTheme.labelFont, fontColor: UIColor.label)
    }
    
    static var labelFont: UIFont {
        return ChartTheme.fontWithSize(DeviceEnv.iPad ? 14 : 11)
    }
    
    static var labelFontSmall: UIFont {
        return ChartTheme.fontWithSize(DeviceEnv.iPad ? 12 : 10)
    }
    
    static func fontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    
    static var guidelinesWidth: CGFloat {
        return DeviceEnv.iPad ? 0.5 : 0.1
    }
    
    static var minBarSpacing: CGFloat {
        return DeviceEnv.iPad ? 10 : 5
    }
}
