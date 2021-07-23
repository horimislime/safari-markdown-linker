//
//  Setting.swift
//  SafariMarkdownLinker
//
//  Created by horimislime on 2021/07/14.
//  Copyright © 2021 horimislime. All rights reserved.
//

import Foundation

struct Setting: Codable {
    var urlFormats: [URLFormat]
    
    static let `default` = Setting(urlFormats: [
        URLFormat(name: "Markdown", pattern: "[%TITLE](%URL)", isEnabled: true, commandName: "Command1"),
        URLFormat(name: "Scrapbox", pattern: "[%TITLE %URL]", isEnabled: true, commandName: "Command2")
    ])
    
    static func load() -> Self? {
        guard let defaults = UserDefaults(suiteName: "me.horimisli.url-linker") else { preconditionFailure() }
        if let data = defaults.value(forKey: "Setting") as? Data,
           let setting = try? PropertyListDecoder().decode(Setting.self, from: data) {
            return setting
        }
        return nil
    }
    
    func save() {
        let defaults = UserDefaults(suiteName: "me.horimisli.url-linker")
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
