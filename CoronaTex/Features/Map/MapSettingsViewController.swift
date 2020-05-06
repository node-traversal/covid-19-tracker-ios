//
//  MapSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import CoreLocation

class MapSettingsViewController: LocationSettingsViewController<MapSettings> {
    @IBOutlet private weak var selectStateButton: UIButton!
    @IBOutlet private weak var currentLocation: UILabel!
    @IBOutlet private weak var miles: UILabel!
    @IBOutlet private weak var locationRadius: UISlider!
    @IBOutlet private weak var locationRestriction: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let settings = self.settings else { return }
               
        if settings.milesToUser != 0 {
            locationRadius.value = Float(settings.milesToUser)
            locationRestriction.isOn = true
        } else {
            locationRadius.value = 250
            locationRestriction.isOn = false
        }
        
        userLocationUpdated(location: settings.userLocation)
    }
    
    // MARK: - Utilities
    func updateRadiusLabel() {
        if locationRestriction.isOn {
            let radiusText = String(Int(locationRadius.value))
            miles.text = "Radius: \(radiusText) miles"
        } else {
            miles.text = "Radius: All"
        }
    }
    
    // MARK: - Overrides
    
    override func newSettings() -> MapSettings? {
        return MapSettings()
    }
    
    override func selectStateUIButton() -> UIButton? {
        return selectStateButton
    }
    
    override func userLocationUpdated(location: CLLocation?) {
        if let loc = location {
            currentLocation.text = "Current Location: \(format(loc))"
            locationRestriction.isEnabled = true
            locationRestrictionChanged(locationRestriction)
        } else {
            currentLocation.text = "Location Unavailable"
            locationRestriction.isEnabled = false
            locationRestriction.isOn = false
            locationRestrictionChanged(locationRestriction)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let settings = self.settings else { return }
                
        if locationRestriction.isOn {
            settings.milesToUser = Int(locationRadius.value)
        } else {
            settings.milesToUser = 0
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func updateLocation(_ sender: Any) {
        super.retriveCurrentLocation()
    }
    
    @IBAction private func selectState(_ sender: Any) {
        super.pickState(sender)
    }
    
    @IBAction private func locationRadiusUpdated(_ sender: Any) {
        updateRadiusLabel()
    }
    
    @IBAction private func locationRestrictionChanged(_ sender: UISwitch) {
        locationRadius.isEnabled = sender.isOn
        updateRadiusLabel()
    }
}
