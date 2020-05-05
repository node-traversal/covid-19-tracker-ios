//
//  LocationSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class LocationSettingsViewController<T: LocationSettings>: UIViewController {
    var settings: T?
    let allStates: String = "All States"
    var states = [String]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        states = [allStates]
        states.append(contentsOf: CountryData.current.states)
        
        self.settings = self.settings ?? newSettings()
        guard let settings = self.settings else {
            fatalError("Could not create settings")
        }
        guard selectStateUIButton() != nil else {
            fatalError("No select state button provided")
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
