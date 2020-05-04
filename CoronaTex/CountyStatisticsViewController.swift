//
//  CountyStatisticsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import Alamofire

enum CountyGroupBy {
    case none
    case state
    case metro
}

class CountyStatisticsViewController: SectionalTableViewController<Double> {  
    var groupBy: CountyGroupBy = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        requestData()
    }
    
    private func requestData() {
        if let url = Environments.current.confirmedUSCasesUrl {
            AF.request(url).validate().responseString { response in
                if let json = response.value, let jsonData = json.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let cases = try! decoder.decode(ConfirmedCasesData.self, from: jsonData)

                    self.processData(series: cases.series)
                }
            }
        }
    }
    
    private func processData(series: [CountyCaseData]) {
        var sectionMap = [String: TableSection<Double>]()
        
        for county in series {
            if let countyName = county.county,
                let state = county.provinceState,
                let lastValue = county.lastValue,
                county.values.count > 2 {
                let key = "\(state), \(countyName)"
                
                if let population = CountryData.current.population(key),
                    let metroName = CountryData.current.metroName(key),
                    !CountyCensusData.isOtherCategoryKey(key) {
                    let size = county.values.count
                    let prevValue = county.values[size - 2]
                    let newCases = lastValue - prevValue
                    let newCasesPerCapita = Double(newCases) / Double(population)
                    let newCasesPerCapitaText = CasesChartSettings.percentFormat(2).string(for: newCasesPerCapita) ?? ""
                    
                    var tableKey = countyName
                    var grouping = "Counties"
                    switch groupBy {
                    case .none:
                        tableKey = "\(countyName), \(state)"
                        grouping = "Counties"
                    case .state:
                        grouping = state
                    case .metro:
                        if metroName == "Rural" {
                            tableKey = "\(countyName), \(state)"
                        }
                        grouping = "\(state), \(metroName)"
                    }
                    
                    let section = sectionMap[grouping] ?? TableSection<Double>(title: grouping)
                    
                    section.allRows.append(TableRow(
                        label: tableKey,
                        detail: "\(newCasesPerCapitaText) | New: \(String(newCases)) | Total: \(lastValue) | Pop: \(population)",
                        sortKey: Double(newCasesPerCapita)
                    ))
                    sectionMap[grouping] = section
                }
            }
        }
        
        sections = Array(sectionMap.values.sorted())
        switch groupBy {
        case .none:
            reverseSortSectionRows()
        case .state:
            sortSectionRowsByLabels()
        case .metro:
            reverseSortSectionRows()
        }
                
        self.tableView.reloadData()
    }
}
