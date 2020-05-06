//
//  CountyStatisticsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

struct CountyStatistics {
    let metroName: String
    let population: Int
    let totalCases: Int
    let newCases: Int
    let newCasesPerCapita: Double
}

class CountyStatisticsViewController: SectionalTableViewController<Double> {
    private var settings = StatisticsSettings()
    
    var rawData: ConfirmedCasesData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = settings.load()
                
        ConfirmedCasesService.load(processData)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        
        switch identifier {
        case "Stats Settings":
            guard let navController = segue.destination as? UINavigationController,
                let destination = navController.topViewController as? StatisticsSettingsViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            destination.settings = self.settings
        default:
            fatalError("Unexpected navigation: \(identifier)")
        }
    }
    
    @IBAction private func unwindForSettings(sender: UIStoryboardSegue) {
        if let sourceController = sender.source as? StatisticsSettingsViewController {
            settings = sourceController.settings ?? StatisticsSettings()
            settings.save()
            print("Received settings")
            
            // reprocess the raw data using the new settings
            if let data = rawData {
                processData(data: data)
            }
        }
    }
       
    // MARK: - Data Model Processing
    
    private func processData(data: ConfirmedCasesData) {
        let sectionMap = toSections(data.series)
        
        sections = Array(sectionMap.values.sorted())
        switch settings.sortBy {
        case .label:
            sortSectionRowsByLabels()
        default:
            reverseSortSectionRows()
        }
                
        rawData = data
        self.tableView.reloadData()
    }
    
    func toSections(_ series: [CountyCaseData]) -> [String: TableSection<Double>] {
        var sectionMap = [String: TableSection<Double>]()
        var countyMap = [String: CountyStatistics]()
        
        for county in series {
            if let countyName = county.county,
                let state = county.provinceState,
                let lastValue = county.lastValue,
                county.values.count > 2 {
                let key = "\(state), \(countyName)"
                
                if let population = CountryData.current.population(key),
                    let metroName = CountryData.current.metroName(key),
                    !CountyCensusData.isOtherCategoryKey(key)
                    && !settings.isFiltered(key: key, state: state, county: countyName) {
                    let size = county.values.count
                    let prevValue = county.values[size - 2]
                    let newCases = lastValue - prevValue
                    let newCasesPerCapita = Double(newCases) / Double(population)
                    let newCasesPerCapitaText = CasesChartSettings.percentFormat(2).string(for: newCasesPerCapita) ?? ""
                    let tableKey = settings.tableKey(county: countyName, state: state, metro: metroName)
                    let grouping = settings.grouping(county: countyName, state: state, metro: metroName)
                    let section = sectionMap[grouping] ?? TableSection<Double>(title: grouping)
                    
                    section.allRows.append(TableRow(
                        label: tableKey,
                        detail: settings.detail(percent: newCasesPerCapitaText, newCases: newCases, totalCases: lastValue, population: population),
                        sortKey: settings.sortKey(percent: newCasesPerCapita, newCases: newCases, totalCases: lastValue, population: population)
                    ))
                    sectionMap[grouping] = section
                    countyMap[key] = CountyStatistics(
                        metroName: tableKey,
                        population: population,
                        totalCases: lastValue,
                        newCases: newCases,
                        newCasesPerCapita: newCasesPerCapita
                    )
                }
            }
        }
                    
        if settings.groupBy == .metroFlat {
            sectionMap = toMetroArea(data: countyMap)
        }
        
        return sectionMap
    }
    
    func toMetroArea(data: [String: CountyStatistics]) -> [String: TableSection<Double>] {
        var workingData = [String: CountyStatistics]()
        var sectionMap = [String: TableSection<Double>]()

        for (_, row) in data {
            let previousItem = workingData[row.metroName]
            var finalItem = row
            if let previous = previousItem {
                let newCases = row.newCases + previous.newCases
                let population = row.population + previous.population
                let totalCases = row.totalCases + previous.totalCases
                let newCasesPerCapita = row.newCasesPerCapita + previous.newCasesPerCapita
                
                finalItem = CountyStatistics(
                    metroName: row.metroName,
                    population: population,
                    totalCases: totalCases,
                    newCases: newCases,
                    newCasesPerCapita: newCasesPerCapita
                )
            }
            workingData[row.metroName] = finalItem
        }
        
        let section = TableSection<Double>(title: "\(settings.prefix)Metro Areas")
        for (tableKey, row) in workingData {
            let newCasesPerCapitaText = CasesChartSettings.percentFormat(2).string(for: row.newCasesPerCapita) ?? ""
            
            section.allRows.append(TableRow(
                label: tableKey,
                detail: settings.detail(percent: newCasesPerCapitaText, newCases: row.newCases, totalCases: row.totalCases, population: row.population),
                sortKey: settings.sortKey(percent: row.newCasesPerCapita, newCases: row.newCases, totalCases: row.totalCases, population: row.population)
            ))
        }
        
        sectionMap["\(settings.prefix)Metro Areas"] = section
        
        return sectionMap
    }
}
