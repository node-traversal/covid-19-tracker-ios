//
//  MapSettingsViewController.swift
//  EpiCenter
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import CoreLocation

class MapSettingsViewController: LocationSettingsViewController<MapSettings> {
    @IBOutlet private weak var currentLocation: UILabel!
    @IBOutlet private weak var miles: UILabel!
    @IBOutlet private weak var locationRestriction: UISwitch!
    private var defaultMiles = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let settings = self.settings else { return }
               
        if settings.milesToUser != 0 {
            locationRestriction.isOn = true
        } else {
            locationRestriction.isOn = false
        }
        
        userLocationUpdated(location: settings.location)
    }
    
    // MARK: - Utilities
        
    // MARK: - Overrides
    
    override func newSettings() -> MapSettings? {
        return MapSettings()
    }
    
    override func selectStateUIButton() -> UIButton? {
        return UIButton()
    }
    
    override func userLocationUpdated(location: NamedLocation?) {
        if let loc = location {
            currentLocation.text = "Location: \(loc.name) \(format(loc.location))"
            locationRestriction.isEnabled = true
            locationRestriction.isOn = true
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
            settings.milesToUser = Int(defaultMiles)
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
       
    @IBAction private func locationRestrictionChanged(_ sender: UISwitch) {
    }
    
    @IBAction private func selectLocation(_ sender: UIButton) {
        self.pickMetroArea(sender)
    }
}
