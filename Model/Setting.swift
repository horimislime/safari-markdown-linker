//
//  Setting.swift
//  URLLinker
//
//  Created by horimislime on 2021/07/14.
//  Copyright © 2021 horimislime. All rights reserved.
//

import Foundation

// TODO: Replace this team ID prefix with yours!
private let appGroupName = "3XEXW5K93E.url-linker"

struct Setting: Codable {
    var urlFormats: [URLFormat]
    
    static let `default` = Setting(urlFormats: [
        URLFormat(name: "Copy as Markdown Format", pattern: "[%TITLE](%URL)", isEnabled: true, commandName: "Command1")
    ])
    
    static func load() -> Self? {
        guard let defaults = UserDefaults(suiteName: appGroupName) else { preconditionFailure() }
        if let data = defaults.value(forKey: "Setting") as? Data,
           let setting = try? PropertyListDecoder().decode(Setting.self, from: data) {
            return setting
        }
        return nil
    }
    
    func save() {
        let defaults = UserDefaults(suiteName: appGroupName)
        defaults?.setValue(try? PropertyListEncoder().encode(self), forKey: "Setting")
        defaults?.synchronize()
    }
    
    mutating func addFormat(name: String, pattern: String, isEnabled: Bool = true) {
        var updatedFormats: [URLFormat] = []
        for (i, f) in urlFormats.enumerated() {
            updatedFormats.append(URLFormat(name: f.name, pattern: f.pattern, isEnabled: f.isEnabled, commandName: "Command\(i + 1)"))
        }
        updatedFormats.append(URLFormat(name: name, pattern: pattern, isEnabled: isEnabled, commandName: "Command\(updatedFormats.count + 1)"))
        urlFormats = updatedFormats
    }
}

struct URLFormat: Codable {
    let name: String
    let pattern: String
    let isEnabled: Bool
    let commandName: String
}
