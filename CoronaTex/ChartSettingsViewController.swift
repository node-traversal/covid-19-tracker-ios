//
//  ChartSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/25/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class ChartSettingsViewController: UIViewController {
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var perCapita: UISwitch!
    @IBOutlet private weak var lastUpdated: UILabel!
    @IBOutlet private weak var newCases: UISwitch!
    @IBOutlet private weak var selectStateButton: UIButton!
    
    let allStates: String = "All States"
    var settings: CasesChartSettings = CasesChartSettings()
    var states = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        states = [allStates]
        states.append(contentsOf: CountryData.current.states)
        setState(settings.selectedState)
        newCases.isOn = settings.newCases
        perCapita.isOn = settings.perCapita
        lastUpdated.text = settings.lastUpdated
    }
    
    private func setState(_ state: String) {
        self.selectStateButton.setTitle(state.isEmpty || state == allStates ? "Select" : state, for: .normal)
        self.selectStateButton.sizeToFit()
    }
    
    // MARK: - Navigation
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        settings.perCapita = perCapita.isOn
        settings.newCases = newCases.isOn
        
        print("done")
    }
    
    @IBAction private func selectState(_ sender: Any) {
        var selection = 0
        if !self.settings.selectedState.isEmpty {
            selection = states.firstIndex(of: self.settings.selectedState ) ?? 0
        }
        
        ActionSheetStringPicker.show(
            withTitle: "Multiple String Picker",
            rows: self.states,
            initialSelection: selection,
            doneBlock: { _, _, value in
                if let state = value as? String {
                    self.settings.selectedState = state == self.allStates ? "" : state
                    self.setState(state)
                }
                return
            },
            cancel: { _ in return },
            origin: sender
        )
    }
}
