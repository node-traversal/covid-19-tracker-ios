//
//  MapSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class MapSettingsViewController: LocationSettingsViewController<MapSettings> {
    @IBOutlet private weak var selectStateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let settings = self.settings else { return }
    }
    
    // MARK: - Overrides
    
    override func newSettings() -> MapSettings? {
        return MapSettings()
    }
    
    override func selectStateUIButton() -> UIButton? {
        return selectStateButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settings = self.settings else { return }
                
        print("Save settings")
    }
    
    // MARK: - Actions
        
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func selectState(_ sender: Any) {
        super.pickState(sender)
    }
}
