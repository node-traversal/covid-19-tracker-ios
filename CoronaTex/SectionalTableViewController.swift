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
    var rows: [TableRow<KEY>] = []
    
    init(title: String) {
        self.title = title
    }
}

class SectionalTableViewController<KEY: Comparable & LosslessStringConvertible>: UITableViewController {
    var sections: [TableSection<KEY>] = []
    let cellType = "basicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    func sort() {
        sections.sort(by: >)
        sortSectionRows()
    }
    
    func reverseSortSectionRows() {
        for section in sections {
            section.rows.sort(by: >)
        }
    }
    
    func sortSectionRows() {
        for section in sections {
            section.rows.sort()
        }
    }
    
    func sortSectionRowsByLabels() {
        for section in sections {
            section.rows.sort {
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
