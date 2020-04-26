//
//  ChartSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/25/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class ChartSettingsViewController: UIViewController {
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var perCapita: UISwitch!
    @IBOutlet private weak var lastUpdated: UILabel!
    @IBOutlet private weak var newCases: UISwitch!
    
    var settings: CasesChartSettings = CasesChartSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newCases.isOn = settings.newCases
        perCapita.isOn = settings.perCapita
        lastUpdated.text = settings.lastUpdated
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
}
