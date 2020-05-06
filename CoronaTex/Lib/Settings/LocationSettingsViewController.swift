//
//  LocationSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import CoreLocation

class LocationSettingsViewController<T: LocationSettings>: UIViewController, CLLocationManagerDelegate {
    var settings: T?
    private let allStates: String = "All States"
    private var states = [String]()
    private let locationManager = CLLocationManager()
    var locationFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        states = [allStates]
        states.append(contentsOf: CountryData.current.states)
        
        locationFormatter.minimumFractionDigits = 1
        locationFormatter.maximumFractionDigits = 1
        
        self.settings = self.settings ?? newSettings()
        guard let settings = self.settings else {
            fatalError("Could not create settings")
        }
        guard selectStateUIButton() != nil else {
            fatalError("No select state button provided")
        }
               
        locationManager.delegate = self
        if settings.userLocation == nil {
            locationManager.requestWhenInUseAuthorization()
            retriveCurrentLocation()
        }
               
        setState(settings.selectedState)
    }
    
    // MARK: - REQUIRED Overrides
    
    func newSettings() -> T? {
        return nil
    }
    
    func selectStateUIButton() -> UIButton? {
        return nil
    }
    
    // MARK: - OPTIONAL Overrides
    func userLocationUpdated(location: CLLocation?) {}
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
    }
    
    // MARK: - Utilities
    
    func format(_ location: CLLocation) -> String {
        let latitude = locationFormatter.string(from: NSNumber(value: location.coordinate.latitude)) ?? "?"
        let longitude = locationFormatter.string(from: NSNumber(value: location.coordinate.longitude)) ?? "?"
        return "\(latitude) x \(longitude)"
    }
    
    func retriveCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()

        if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
            print("User location not enabled")
            return
        }

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }

        locationManager.requestLocation()
    }
    
    // MARK: - Actions
    
    @IBAction private func getCurrentLocationTapped(_ sender: Any) {
        retriveCurrentLocation()
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // .requestLocation will only pass one location to the locations array
        // hence we can access it by taking the first element of the array
        if let location = locations.first {
            print("User Location: \(format(location))")
            self.settings?.userLocation = location
            userLocationUpdated(location: location)
        } else {
            print("Invalid locations: \(locations)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // might be that user didn't enable location service on the device
        // or there might be no GPS signal inside a building
      
        // might be a good idea to show an alert to user to ask them to walk to a place with GPS signal
        print("Could not aquire user location: \(error)")
    }
    
    // MARK: - State Selection

    func setState(_ state: String) {
        guard
            let settings = self.settings,
            let selectStateButton = selectStateUIButton()
            else { return }
        settings.selectedState = state == self.allStates ? "" : state
        selectStateButton.setTitle(state.isEmpty || state == allStates ? "Select" : state, for: .normal)
        selectStateButton.sizeToFit()
    }
    
    func pickState(_ sender: Any) {
        guard let settings = self.settings else { return }
        var selection = 0
        if !settings.selectedState.isEmpty {
            selection = states.firstIndex(of: settings.selectedState ) ?? 0
        }
        
        let picker = ActionSheetStringPicker(
            title: "Select State",
            rows: self.states,
            initialSelection: selection,
            doneBlock: { _, _, value in
                if let state = value as? String {
                    self.setState(state)
                }
                return
            },
            cancel: { _ in
                self.setState("")
            },
            origin: sender
        )
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Clear", for: .normal)
        cancelButton.setTitleColor(self.view.tintColor, for: .normal)
        cancelButton.setTitleColor(UIColor.systemRed, for: .highlighted)
        
        picker?.setCancelButton(UIBarButtonItem.init(customView: cancelButton))
        picker?.show()
    }
}
