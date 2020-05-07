//
//  ConfirmedCases.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/20/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import Alamofire

struct CountyCaseData: Codable {
    var county: String?
    var provinceState: String?
    var latitude: Double?
    var longitude: Double?
    var values: [Int]
    var lastValue: Int?
    }

enum ConfirmedCasesService {
    private static var current: ConfirmedCasesData?
    
    static func load(_ completion: @escaping (ConfirmedCasesData) -> Void) {
        if let instance = ConfirmedCasesService.current,
            instance.isUpToDate {
            completion(instance)
        } else if let url = Environments.current.confirmedUSCasesUrl {
            AF.request(url).validate().responseString { response in
                if let json = response.value, let jsonData = json.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let cases = try! decoder.decode(ConfirmedCasesData.self, from: jsonData)
                    current = cases
                    completion(cases)
                }
            }
        }
    }
}

class ConfirmedCasesData: Codable {
    static let dateFormat = "yyyy-MM-dd"
    
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    var dates: [String]
    var series: [CountyCaseData]
    
    var isUpToDate: Bool {
        if let lastUpdated = dates.last {
            let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let expectedDateText = ConfirmedCasesData.dateFormatter().string(from: expectedDate)
            if expectedDateText == lastUpdated {
                return true
            }
            print("ConfirmedCasesData: lasted updated: \(lastUpdated) \(expectedDateText)")
        }
        return false
    }
}
