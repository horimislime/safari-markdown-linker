//
//  SafariWebExtensionHandler.swift
//  URL Linker Extension
//
//  Created by horimislime on 2021/09/07.
//  Copyright © 2021 horimislime. All rights reserved.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    private let userDefaults = UserDefaults(suiteName: "group.me.horimisli.URLLinker")!

    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        guard let message = item.userInfo?[SFExtensionMessageKey] as? [String: AnyObject] else {
            os_log(.default, "Invalid native request payload")
            return
        }
        os_log(.default, "Received message from browser.runtime.sendNativeMessage: %@", message as CVarArg)
        
        let setting = Setting.load(from: userDefaults) ?? Setting.default
        let response = NSExtensionItem()
        if message["request"] as! String == "getFormats" {
            let formats = setting.urlFormats.map { ["name": $0.name, "command": $0.commandName] }
            response.userInfo = [SFExtensionMessageKey: formats]
        } else if message["request"] as! String == "copy" {
            let payload = message["payload"] as! [String: String]
            let title = payload["title"]!
            let link = payload["link"]!
            let command = payload["command"]!
            guard let format = setting.urlFormats.first(where: { $0.commandName == command }) else { return }
            let formattedString = format.pattern
                .replacingOccurrences(of: "%URL", with: link)
                .replacingOccurrences(of: "%TITLE", with: title)
            UIPasteboard.general.string = formattedString
        } else {
            
        }
        
        os_log(.default, "sendNativeMessage: Load setting")
        
        

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
