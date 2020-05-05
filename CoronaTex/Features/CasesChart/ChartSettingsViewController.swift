//
//  ChartSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/25/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class ChartSettingsViewController: LocationSettingsViewController<CasesChartSettings> {
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var perCapita: UISwitch!
    @IBOutlet private weak var lastUpdated: UILabel!
    @IBOutlet private weak var newCases: UISwitch!
    @IBOutlet private weak var metroArea: UISwitch!
    @IBOutlet private weak var selectStateButton: UIButton!
    @IBOutlet private weak var topXSelector: UISegmentedControl!
    @IBOutlet private weak var daySelector: UISegmentedControl!
    @IBOutlet private weak var smoothingSelector: UISegmentedControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        guard let settings = self.settings else { return }
        
        newCases.isOn = settings.isNewCases
        perCapita.isOn = settings.isPerCapita
        metroArea.isOn = settings.isMetroGrouped
        lastUpdated.text = settings.lastUpdated
        topXSelector.selectedSegmentIndex = CasesChartSettings.topSelections.firstIndex(of: settings.top) ?? 0
        smoothingSelector.selectedSegmentIndex = CasesChartSettings.smoothingSelections.firstIndex(of: settings.smoothing) ?? 0
        daySelector.selectedSegmentIndex = CasesChartSettings.findDayIndex(settings.lastDays)
    }
    
    // MARK: - Overrides
    
    override func newSettings() -> CasesChartSettings? {
        return CasesChartSettings()
    }
    
    override func selectStateUIButton() -> UIButton? {
        return selectStateButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let settings = self.settings else { return }
        
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
    
    // MARK: - Actions
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func selectState(_ sender: Any) {
        super.pickState(sender)
    }
}
