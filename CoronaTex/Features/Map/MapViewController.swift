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
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var dateScrubber: UISlider!
    @IBOutlet private weak var dateSliderLabel: UILabel!
    @IBOutlet private weak var playbackButton: UIButton!
    
    static var defaultDateIndex = 44
    
    let initialLocation = CLLocation(latitude: 39.8283, longitude: -98.5795)
    let mapMin = 600000.0
    let mapMax = 7000000.0
    var rawData: ConfirmedCasesData?
    var dateIndex: Int = 0
    var timer: Timer?
    var playImage = UIImage(systemName: "play.fill")!
    var stopImage = UIImage(systemName: "stop.fill")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isRotateEnabled = false
        playbackButton.isEnabled = false
        playbackButton.setBackgroundImage(playImage, for: .normal)
        
        //mapView.mapType = .mutedStandard
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: mapMin, maxCenterCoordinateDistance: mapMax)
        mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(
            center: initialLocation.coordinate, latitudinalMeters: 3000000.0, longitudinalMeters: 5000000.0))
        
        reset()
    }
    
    func stopPlayback() {
        print("playback completed/stopped @ index: \(dateIndex)")
        timer?.invalidate()
        timer = nil
        playbackButton.setBackgroundImage(playImage, for: .normal)
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
    
    func createTimer() {
        guard timer == nil, let data = rawData else { return }

        if dateIndex > data.dates.count - 7 {
            dateIndex = MapViewController.defaultDateIndex
        }
            
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func reset() {
        guard let mapView = self.mapView else { return }
        dateScrubber.isEnabled = false
        dateSliderLabel.text = "--/--/--"
        
        mapView.removeOverlays(mapView.overlays)
        
        mapView.centerToLocation(initialLocation, regionRadius: mapMax)
        
        requestData()
    }
    
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
    
    func setDateSliderLabel(index: Int) {
        guard let data = rawData else { return }
        
        if index < data.dates.count {
            dateSliderLabel.text = data.dates[index]
        } else {
            dateSliderLabel.text = data.dates.last ?? "August 4th, 1997"
        }
        dateIndex = index
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
    
    func processData(_ data: ConfirmedCasesData) {
        guard self.mapView != nil else { fatalError("expected mapView to be loaded") }
        guard !data.dates.isEmpty else { return }
        
        let series = data.series
        self.rawData = data
        
        playbackButton.isEnabled = true
        dateScrubber.isEnabled = true
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
                lastValue > 150 {
                let ratio = min(max(Double(newCases), minRadius) / maxRadius, 1.0)
                let color = minColor.interpolateRGBColorTo(maxColor, fraction: CGFloat(ratio))
                
                rMax = max(ratio, rMax)
                
                if ratio >= 0.75 {
                    print("\(countyName) \(ratio)")
                }
                
                self.showCircle(
                    CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    radius: 90000.0 * ratio,
                    color: color ?? .blue,
                    alpha: ratio >= 0.75 ? 1.0 : 0.3
                )
            }
        }
        
        print("Avg new: \(sumCases / casesCount), \(rMax) \(totalCasesMax) \(index)")
    }
    
    func showCircle(_ coordinate: CLLocationCoordinate2D, radius: Double, color: UIColor, alpha: Double) {
        guard let mapView = self.mapView else { return }
        
        let circle = CaseCircle(center: coordinate, radius: CLLocationDistance(radius))
        circle.color = color
        
        mapView.addOverlay(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? CaseCircle else {
            fatalError("not a circle \(overlay)")
        }
        
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        circleRenderer.fillColor = circleOverlay.color
        circleRenderer.alpha = 0.3

        return circleRenderer
    }
}

extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 4500000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

extension UIColor {
    func interpolateRGBColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor? {
        let fractional = min(max(0, fraction), 1)

        guard let comp1 = self.cgColor.components, let comp2 = end.cgColor.components else { return nil }

        let red: CGFloat = CGFloat(comp1[0] + (comp2[0] - comp1[0]) * fractional)
        let green: CGFloat = CGFloat(comp1[1] + (comp2[1] - comp1[1]) * fractional)
        let blue: CGFloat = CGFloat(comp1[2] + (comp2[2] - comp1[2]) * fractional)

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
