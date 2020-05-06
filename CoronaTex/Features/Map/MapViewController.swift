//
//  MapViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/2/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class CaseCircle: MKCircle {
    var color: UIColor = .red
}

class MapViewController: UIViewController, MKMapViewDelegate {
    let defaultDateIndex = 44
    let initialLocation = CLLocation(latitude: 39.8283, longitude: -98.5795)
    let mapMin = 600000.0
    let mapMax = 7000000.0
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var dateScrubber: UISlider!
    @IBOutlet private weak var dateSliderLabel: UILabel!
    @IBOutlet private weak var playbackButton: UIButton!
    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    
    var timer: Timer?
    var rawData: ConfirmedCasesData?
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
            createTimer()
            playbackButton.setBackgroundImage(stopImage, for: .normal)
        } else {
            stopPlayback()
        }
    }
    
    @IBAction private func dateScrubberChanged(_ sender: UISlider) {
        guard let data = rawData else { return }
        let currentDateindex = Int(sender.value)
        
        guard dateIndex != currentDateindex else {
            print("Same date index: \(dateIndex)")
            return
        }
        
        mapView.removeOverlays(mapView.overlays)

        processSerries(data.series, index: currentDateindex - 1)
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
    
    func location() -> CLLocation {
        return settings.userLocation ?? initialLocation
    }
        
    func reset() {
        guard let mapView = self.mapView else { return }
        dateScrubber.isEnabled = false
        dateSliderLabel.text = "--/--/--"
        
        mapView.removeOverlays(mapView.overlays)
        
        mapView.centerToLocation(location(), regionRadius: mapMax)
        
        requestData()
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
            
            // reprocess the raw data using the new settings
            if let rawData = self.rawData {
                processData(rawData)
            }
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
    
    func showCircle(_ coordinate: CLLocationCoordinate2D, radius: Double, color: UIColor) {
        guard let mapView = self.mapView else { return }
        
        let circle = CaseCircle(center: coordinate, radius: CLLocationDistance(radius))
        circle.color = color
        
        mapView.addOverlay(circle)
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
        processSerries(data.series, index: dateIndex)
    }
    
    func stopPlayback() {
        print("playback completed/stopped @ index: \(dateIndex)")
        timer?.invalidate()
        timer = nil
        playbackButton.setBackgroundImage(playImage, for: .normal)
    }
    
    // MARK: - Web Service Request
    
    private func requestData() {
        if let url = Environments.current.confirmedUSCasesUrl {
            AF.request(url).validate().responseString { response in
                if let json = response.value, let jsonData = json.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let cases = try! decoder.decode(ConfirmedCasesData.self, from: jsonData)

                    self.processData(cases)
                }
            }
        }
    }
    
    // MARK: - Data Processing
    
    func processData(_ data: ConfirmedCasesData) {
        guard self.mapView != nil else { fatalError("expected mapView to be loaded") }
        guard !data.dates.isEmpty else { return }
        
        let series = data.series
        self.rawData = data
        
        playbackButton.isEnabled = true
        dateScrubber.isEnabled = true
        refreshButton.isEnabled = true
        settingsButton.isEnabled = true
        dateIndex = data.dates.count - 1
        
        processSerries(series, index: dateIndex)
             
        dateScrubber.minimumValue = 40
        dateScrubber.maximumValue = Float(data.dates.count)
        dateScrubber.value = Float(dateIndex)
        
        setDateSliderLabel(index: dateIndex)
        
        print("done")
    }
    
    func processSerries(_ series: [CountyCaseData], index: Int) {
        let minRadius = 50.0
        let maxRadius = 1000.0
        let start: Double = CACurrentMediaTime()
        var sumCases = 0
        var casesCount = 0
        let minColor = UIColor.blue
        let maxColor = UIColor.red
        var rMax = 0.0
        var totalCasesMax = 0
        for county in series {
            let lastValue = county.values[index]
            let prevValue = county.values[index - 1]
            let newCases = lastValue - prevValue
            sumCases += newCases
            casesCount += 1
            totalCasesMax = max(totalCasesMax, lastValue)
            
            if
                let countyName = county.county,
                let state = county.provinceState,
                let latitude = county.latitude,
                let longitude = county.longitude,
                lastValue > 0 {
                if !settings.selectedState.isEmpty {
                    if settings.selectedState != state {
                        continue
                    }
                } else if let location = settings.userLocation {
                    let distance = Measurement(value: location.distance(from: CLLocation(latitude: latitude, longitude: longitude)), unit: UnitLength.meters)
                    let miles = Int(distance.converted(to: .miles).value)
                                        
                    if settings.milesToUser > 0 && miles > settings.milesToUser {
                        continue
                    }
                }
                let ratio = min(max(Double(newCases), minRadius) / maxRadius, 1.0)
                let color = minColor.interpolateRGBColorTo(maxColor, fraction: CGFloat(ratio))
                
                rMax = max(ratio, rMax)
                
                if ratio >= 0.75 {
                    print("\(countyName) \(ratio)")
                }
                
                self.showCircle(
                    CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    radius: 90000.0 * ratio,
                    color: color ?? .blue
                )
            }
        }
        
        let end: Double = CACurrentMediaTime()
        let elpased = end - start
        print("Avg new: \(sumCases / casesCount), \(rMax) \(totalCasesMax) \(index) \(elpased)")
        print("done")
    }
}

//        if let location = self.settings.userLocation {
//            self.showCircle(
//                location.coordinate,
//                radius: 90000.0 ,
//                color: .green,
//                alpha: 0.3
//            )
//            mapView.centerToLocation(location, regionRadius: mapMax)
//        }
//
