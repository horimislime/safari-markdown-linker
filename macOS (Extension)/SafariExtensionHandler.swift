//
//  SafariExtensionHandler.swift
//  SafariExtension
//
//  Created by horimislime on 2017/09/10.
//  Copyright © 2017 horimislime. All rights reserved.
//

import AppKit
import SafariServices
import os.log

private var lastLinkDetail: [String: Any]?

class SafariExtensionHandler: SFSafariExtensionHandler {
    // TODO: Replace this team ID prefix with yours!
    private let userDefaults = UserDefaults(suiteName: "3XEXW5K93E.url-linker")!
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        lastLinkDetail = userInfo
    }
    
    override func validateContextMenuItem(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil, validationHandler: @escaping (Bool, String?) -> Void) {
        if let format = getAssociatedFormat(withCommand: command) {
            validationHandler(!format.isEnabled, "\(format.name)")
        } else {
            validationHandler(true, nil)
        }
    }
    
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        guard let format = getAssociatedFormat(withCommand: command) else { return }
        
        if let title = lastLinkDetail?["title"] as? String, let urlString = lastLinkDetail?["url"] as? String, let url = URL(string: urlString) {
            copyWithFormat(format, title: title, url: url)
            return
        }
        
        page.getPropertiesWithCompletionHandler { properties in
            guard let title = properties?.title, let url = properties?.url else { return }
            self.copyWithFormat(format, title: title, url: url)
        }
    }
    
    private func copyWithFormat(_ format: URLFormat, title: String, url: URL) {
        NSPasteboard.general.clearContents()
        let formattedString = format.pattern
            .replacingOccurrences(of: "%URL", with: url.absoluteString)
            .replacingOccurrences(of: "%TITLE", with: title)
        NSPasteboard.general.setString(formattedString, forType: NSPasteboard.PasteboardType.string)
    }
    
    private func getAssociatedFormat(withCommand command: String) -> URLFormat? {
        let setting = Setting.load(from: userDefaults) ?? Setting.default
        return setting.urlFormats.first { f in f.commandName == command }
    }
}
