//
//  SectionalTableViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/4/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class TableSection<KEY: Comparable & LosslessStringConvertible>: Comparable {
    static func < (lhs: TableSection<KEY>, rhs: TableSection<KEY>) -> Bool {
        lhs.title < rhs.title
    }
    
    static func == (lhs: TableSection<KEY>, rhs: TableSection<KEY>) -> Bool {
        lhs.title == rhs.title
    }
    
    var title: String
    var allRows: [TableRow<KEY>] = []
    private var filteredRows: [TableRow<KEY>]?
    var rows: [TableRow<KEY>] {
        filteredRows ?? allRows
    }
    
    init(title: String) {
        self.title = title
    }
    
    func clearFilter() {
        filteredRows = nil
    }
    
    func filter(for searchText: String) {
        filteredRows = allRows.filter {
            let match = $0.label.range(of: searchText, options: .caseInsensitive)
            // Return the tuple if the range contains a match.
            return match != nil
        }
    }
}

class SectionalTableViewController<KEY: Comparable & LosslessStringConvertible>: UITableViewController, UISearchResultsUpdating {
    var sections: [TableSection<KEY>] = []
    private let cellType = "basicCell"
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true

        // Place the search bar in the table view's header.
        self.tableView.tableHeaderView = searchController.searchBar

        // Set the content offset to the height of the search bar's height
        // to hide it when the view is first presented.
        self.tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText.isEmpty {
                clearfilter()
            } else {
                filterContent(for: searchText)
            }
            
            tableView.reloadData()
        }
    }
    
    func clearfilter() {
        for section in sections {
            section.clearFilter()
        }
    }
    
    func filterContent(for searchText: String) {
        for section in sections {
            section.filter(for: searchText)
        }
    }
    
    func sort() {
        sections.sort(by: >)
        sortSectionRows()
    }
    
    func reverseSortSectionRows() {
        for section in sections {
            section.allRows.sort(by: >)
        }
    }
    
    func sortSectionRows() {
        for section in sections {
            section.allRows.sort()
        }
    }
    
    func sortSectionRowsByLabels() {
        for section in sections {
            section.allRows.sort {
                $0.label < $1.label
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellType)

        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellType)
        }
        
        let rows = sections[indexPath.section].rows
        let row = rows[indexPath.row]
        cell!.textLabel?.text = row.label
        cell!.detailTextLabel?.text = row.detail

        return cell!
    }
}
