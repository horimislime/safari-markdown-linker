//
//  Setting.swift
//  SafariMarkdownLinker
//
//  Created by horimislime on 2021/07/14.
//  Copyright © 2021 horimislime. All rights reserved.
//

import Foundation

struct Setting: Codable {
    let urlFormats: [URLFormat]
    
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
}

struct URLFormat: Codable {
    let name: String
    let pattern: String
    let isEnabled: Bool
    let commandName: String
}
