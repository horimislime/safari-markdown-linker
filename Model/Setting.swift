//
//  Setting.swift
//  SafariMarkdownLinker
//
//  Created by horimislime on 2021/07/14.
//  Copyright © 2021 horimislime. All rights reserved.
//

import Foundation

private let commands = [
    "Command1",
    "Command2",
    "Command3",
    "Command4",
    "Command5",
]

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
        let currentCommands = urlFormats.map { $0.commandName }
        guard let change = commands.difference(from: currentCommands).first else { return }
        switch change {
        case .insert(_, let commandName, _):
            urlFormats += [URLFormat(name: name, pattern: pattern, isEnabled: isEnabled, commandName: commandName)]
        default:
            break
        }
    }
}

struct URLFormat: Codable {
    let name: String
    let pattern: String
    let isEnabled: Bool
    let commandName: String
}
