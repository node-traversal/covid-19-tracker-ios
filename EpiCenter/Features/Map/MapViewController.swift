//
//  MapViewController.swift
//  EpiCenter
//
//  Created by Allen Parslow on 5/2/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//
// swiftlint:disable operator_usage_whitespace

import UIKit
import MapKit

class CaseCircle: MKCircle, Comparable {
    static func < (lhs: CaseCircle, rhs: CaseCircle) -> Bool {
        lhs.value < rhs.value
    }
    
    var key: String?
    var color: UIColor = .red
    var value: Double = 0.0
    
    convenience init(_ coordinate: CLLocationCoordinate2D, key: String, value: Double, radius: Double, color: UIColor) {
        self.init(center: coordinate, radius: CLLocationDistance(radius))
        self.color = color
        self.value = value
        self.key = key
    }
}

class DateInfo {
    let date: String
    var points = [CaseCircle]()
    
    init(_ date: String) {
        self.date = date
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    let defaultDateIndex = 44
    let initialLocation = CLLocation(latitude: 39.8283, longitude: -98.5795)
    let mapMin =     600000.0
    let mapZoomed = 1000000.0
    let mapMax =    9500000.0
    let maxUnfilteredSize = 200
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var dateScrubber: UISlider!
    @IBOutlet private weak var dateSliderLabel: UILabel!
    private var playbackButton = UIButton()
    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    
    var timer: Timer?
    var rawData: ConfirmedCasesData?
    var dateEntries: [DateInfo]?
    var dateIndex: Int = 0
    var settings = MapSettings()
    var playImage = UIImage(systemName: "play.fill")!
    var stopImage = UIImage(systemName: "stop.fill")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settings = settings.load()
        
        mapView.delegate = self
        mapView.isRotateEnabled = false
        playbackButton.isEnabled = false
        playbackButton.isHidden = true
        refreshButton.isEnabled = false
        settingsButton.isEnabled = false
        playbackButton.setBackgroundImage(playImage, for: .normal)
        
        //mapView.mapType = .mutedStandard
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: mapMin, maxCenterCoordinateDistance: mapMax)
        mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(
            center: initialLocation.coordinate, latitudinalMeters: 3000000.0, longitudinalMeters: 5000000.0))
        
        reset()
    }
    
    // MARK: - Actions
    
    @IBAction private func clear(_ sender: Any) {
        reset()
    }
    
    @IBAction private func startPlayback(_ sender: Any) {
        if timer == nil {
            mapView.removeOverlays(mapView.overlays)
            createTimer()
            playbackButton.setBackgroundImage(stopImage, for: .normal)
        } else {
            stopPlayback()
        }
    }
    
    @IBAction private func dateScrubberChanged(_ sender: UISlider) {
        let currentDateindex = Int(sender.value)
        
        guard dateIndex != currentDateindex else {
            print("Same date index: \(dateIndex)")
            return
        }
        
        mapView.removeOverlays(mapView.overlays)

        updatePoints()
        setDateSliderLabel(index: currentDateindex)
    }
    
    // MARK: - Utilities
     
    func setDateSliderLabel(index: Int) {
        guard let data = rawData else { return }
        
        if index < data.dates.count {
            dateSliderLabel.text = data.dates[index]
        } else {
            dateSliderLabel.text = data.dates.last ?? "August 4th, 1997"
        }
        dateIndex = index
    }
        
    func zoomToLocation() {
        if let location = self.settings.location, settings.milesToUser > 0 {
            mapView.centerToLocation(location.location, regionRadius: mapZoomed)
        } else {
            mapView.centerToLocation(initialLocation, regionRadius: mapMax)
        }
    }
    
    func reset() {
        guard let mapView = self.mapView else { return }
        dateScrubber.isEnabled = false
        dateSliderLabel.text = "--/--/--"
        
        mapView.removeOverlays(mapView.overlays)
        
        zoomToLocation()
        
        ConfirmedCasesService.load(processData)
    }
    
    // MARK: - Navigation
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        
        switch identifier {
        case "Map Settings":
            guard let navController = segue.destination as? UINavigationController,
                let destination = navController.topViewController as? MapSettingsViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            destination.settings = self.settings
        default:
            fatalError("Unexpected navigation: '\(identifier)'")
        }
    }
    
    @IBAction private func unwindForSettings(sender: UIStoryboardSegue) {
        if let sourceController = sender.source as? MapSettingsViewController {
            guard let settings = sourceController.settings else {
                fatalError("Controller did not have settings")
            }
            self.settings = settings
            settings.save()
            print("Received settings")
            
            reset()
        }
    }
    
    // MARK: - Map Marker Rendering
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? CaseCircle else {
            fatalError("not a circle \(overlay)")
        }
        
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        circleRenderer.fillColor = circleOverlay.color
        circleRenderer.alpha = 0.3

        return circleRenderer
    }
    
    // MARK: - Playback: Timeline
    
    func createTimer() {
        guard timer == nil, let data = rawData else { return }

        if dateIndex > data.dates.count - 7 {
            dateIndex = defaultDateIndex
        }
            
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
        
    @objc
    func updateTimer() {
        guard let data = rawData, dateIndex < data.dates.count - 1 else {
            stopPlayback()
            return
        }
        dateIndex += 1
        
        dateScrubber.value = Float(dateIndex)
        setDateSliderLabel(index: dateIndex)
        updatePoints()
    }
    
    func stopPlayback() {
        print("playback completed/stopped @ index: \(dateIndex)")
        timer?.invalidate()
        timer = nil
        playbackButton.setBackgroundImage(playImage, for: .normal)
    }
       
    // MARK: - Data Processing
    
    func updatePoints() {
        guard let mapView = self.mapView else { return }
        guard let dates = self.dateEntries else { return }

        let points = dates[dateIndex - 1].points
        for point in points {
            mapView.addOverlay(point)
        }
    }
    
    func updatePoints(_ points: [CaseCircle]) {
        guard let mapView = self.mapView else { return }
        
        for point in points {
            mapView.addOverlay(point)
        }
    }
    
    func processData(_ data: ConfirmedCasesData) {
        guard self.mapView != nil else { fatalError("expected mapView to be loaded") }
        guard !data.dates.isEmpty else { return }
        
        self.rawData = data
        
        playbackButton.isEnabled = true
        dateScrubber.isEnabled = true
        refreshButton.isEnabled = true
        settingsButton.isEnabled = true
        dateIndex = data.dates.count - 1
        
        self.dateEntries = processSeries(data: data)
        updatePoints()
             
        dateScrubber.minimumValue = 40
        dateScrubber.maximumValue = Float(data.dates.count)
        dateScrubber.value = Float(dateIndex)
        
        setDateSliderLabel(index: dateIndex)
        
        zoomToLocation()
        
        print("done")
    }
    
    func processSeries(data: ConfirmedCasesData) -> [DateInfo] {
        let minRadius = 50.0
        let maxRadius = 1000.0
        let minColor = UIColor.blue
        let maxColor = UIColor.red
        
        var entries = [DateInfo]()
        for date in data.dates {
            entries.append(DateInfo(date))
        }
                
        for county in data.series {
            if
                let countyName = county.county,
                let state = county.provinceState,
                let totalCases = county.lastValue,
                let latitude = county.latitude,
                let longitude = county.longitude,
                totalCases > 0 {
                let key = "\(state), \(countyName)"
                if settings.isFiltered(county: county) {
                    continue
                }
                print("C: \(key): \(totalCases)")
                var prevValueOptional: Int?
                for (index, lastValue ) in county.values.enumerated() {
                    if let previousValue = prevValueOptional {
                        let newCases = lastValue - previousValue
                        let ratio = min(max(Double(newCases), minRadius) / maxRadius, 1.0)
                        let color = minColor.interpolateRGBColorTo(maxColor, fraction: CGFloat(ratio)) ?? .blue
                                        
                        if ratio >= 0.75 {
                            print("\(countyName) \(ratio)")
                        }
                        if newCases > 0 {
                            entries[index].points.append(CaseCircle(
                                CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                key: key,
                                value: Double(newCases),
                                radius: 90000.0 * ratio,
                                color: color
                            ))
                        }
                    }
                    prevValueOptional = lastValue
                }
            }
        }
        
        for date in entries {
            date.points.sort(by: >)
            if !date.points.isEmpty {
                let newPoints = Array(date.points[0...min(date.points.count - 1, maxUnfilteredSize)])
                date.points = newPoints
            }
        }
        
        return entries
    }
}
