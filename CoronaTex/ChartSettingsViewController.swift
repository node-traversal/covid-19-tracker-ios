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
    @IBOutlet private weak var metroArea: UISwitch!
    @IBOutlet private weak var selectStateButton: UIButton!
    @IBOutlet private weak var topXSelector: UISegmentedControl!
    @IBOutlet private weak var daySelector: UISegmentedControl!
    @IBOutlet private weak var smoothingSelector: UISegmentedControl!
    
    let allStates: String = "All States"
    var settings: CasesChartSettings = CasesChartSettings()
    var states = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        states = [allStates]
        states.append(contentsOf: CountryData.current.states)
        setState(settings.selectedState)
        newCases.isOn = settings.isNewCases
        perCapita.isOn = settings.isPerCapita
        metroArea.isOn = settings.isMetroGrouped
        lastUpdated.text = settings.lastUpdated
        topXSelector.selectedSegmentIndex = CasesChartSettings.topSelections.firstIndex(of: settings.top) ?? 0
        smoothingSelector.selectedSegmentIndex = CasesChartSettings.smoothingSelections.firstIndex(of: settings.smoothing) ?? 0
        daySelector.selectedSegmentIndex = CasesChartSettings.findDayIndex(settings.lastDays)
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
        settings.isPerCapita = perCapita.isOn
        settings.isNewCases = newCases.isOn
        settings.isMetroGrouped = metroArea.isOn
        settings.top = CasesChartSettings.topSelections[topXSelector.selectedSegmentIndex]
        settings.smoothing = CasesChartSettings.smoothingSelections[smoothingSelector.selectedSegmentIndex]
        let dayRange = CasesChartSettings.daySelections[daySelector.selectedSegmentIndex]
        settings.lastDays = dayRange[0]
        settings.limitDays = dayRange[1]
        
        print("Save settings")
    }
    
    @IBAction private func selectState(_ sender: Any) {
        var selection = 0
        if !self.settings.selectedState.isEmpty {
            selection = states.firstIndex(of: self.settings.selectedState ) ?? 0
        }
        
        let picker = ActionSheetStringPicker(
            title: "Select State",
            rows: self.states,
            initialSelection: selection,
            doneBlock: { _, _, value in
                if let state = value as? String {
                    self.settings.selectedState = state == self.allStates ? "" : state
                    self.setState(state)
                }
                return
            },
            cancel: { _ in
                self.settings.selectedState = ""
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
