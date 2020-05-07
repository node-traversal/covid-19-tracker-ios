//
//  UrlManager.swift
//  EpiCenter
//
//  Created by Allen Parslow on 4/24/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

struct EnvironmentData: Codable {
    var confirmedUSCasesUrl: String?
}

enum Environments {
    static var current = Environments.load()

    private static func load() -> EnvironmentData {
        guard let path = Bundle.main.path(forResource: "Urls", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) else { fatalError("Could not find url definitions") }
        guard let environment = try? PropertyListDecoder().decode(EnvironmentData.self, from: xml) else { fatalError("Could not load url definitions") }
        
        return environment
    }
}
