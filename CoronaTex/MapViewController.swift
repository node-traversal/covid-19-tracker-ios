//
//  MapViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/2/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import Mapbox
import MapKit

class MapViewController: UIViewController, MGLMapViewDelegate {
    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Create and add a map view.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 31.31, longitude: -99.06), zoomLevel: 3, animated: false)
        
        mapView.delegate = self
        mapView.tintColor = .lightGray
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        // Parse GeoJSON data. This example uses all M1.0+ earthquakes from 12/22/15 to 1/21/16 as logged by USGS' Earthquake hazards program.
        guard let url = URL(string: "https://raw.githubusercontent.com/node-traversal/covid-19-tracker-ios/master/geo.json") else { return }
        let source = MGLShapeSource(identifier: "earthquakes", url: url, options: nil)
        
        //          let feature = MGLPointFeature()
        //            feature.title = "F"
        //            feature.coordinate = CLLocationCoordinate2D(latitude: 37.77, longitude: -122.42)
        //                feature.attributes = [
        //                    "mag": 5.0
        //                ]
        //            let source = MGLShapeSource(identifier: "earthquakes", features: [feature])
        //        let fsss = source.features(matching: nil)
        //            print(fsss.count)
        //            for feat in fsss {
        //                print(feat)
        //            }
        style.addSource(source)
        
        // Create a heatmap layer.
        let heatmapLayer = MGLHeatmapStyleLayer(identifier: "earthquakes", source: source)
        
        // Adjust the color of the heatmap based on the point density.
        let colorDictionary: [NSNumber: UIColor] = [
            0.0: .clear,
            0.01: .white,
            0.15: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0),
            0.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
            1: .yellow
        ]
        heatmapLayer.heatmapColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($heatmapDensity, 'linear', nil, %@)", colorDictionary)
        
        // Heatmap weight measures how much a single data point impacts the layer's appearance.
        heatmapLayer.heatmapWeight = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)",
            [
                0: 0,
                6: 1
            ]
        )
        
        // Heatmap intensity multiplies the heatmap weight based on zoom level.
        heatmapLayer.heatmapIntensity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [
                0: 1,
                9: 3
            ]
        )
        heatmapLayer.heatmapRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [
                0: 4,
                9: 30
            ]
        )
        
        // The heatmap layer should be visible up to zoom level 9.
        heatmapLayer.heatmapOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0.75, %@)", [0: 0.75, 9: 0])
        style.addLayer(heatmapLayer)
        
        // Add a circle layer to represent the earthquakes at higher zoom levels.
        let circleLayer = MGLCircleStyleLayer(identifier: "circle-layer", source: source)
        
        let magnitudeDictionary: [NSNumber: UIColor] = [
            0: .white,
            0.5: .yellow,
            2.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
            5: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0)
        ]
        circleLayer.circleColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)", magnitudeDictionary)
        
        // The heatmap layer will have an opacity of 0.75 up to zoom level 9, when the opacity becomes 0.
        circleLayer.circleOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0, %@)", [0: 0, 9: 0.75])
        circleLayer.circleRadius = NSExpression(forConstantValue: 20)
        style.addLayer(circleLayer)
    }
}
