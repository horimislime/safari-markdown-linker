//
//  SafariExtensionHandler.swift
//  SafariExtension
//
//  Created by horimislime on 2017/09/10.
//  Copyright © 2017 horimislime. All rights reserved.
//

import AppKit
import SafariServices

private var lastLinkDetail: [String: Any]?

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        lastLinkDetail = userInfo
    }
    
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        
        if let title = lastLinkDetail?["title"] as? String, let urlString = lastLinkDetail?["url"] as? String, let url = URL(string: urlString) {
            copyAsMarkdown(withTitle: title, url: url)
            return
        }
        
        page.getPropertiesWithCompletionHandler { properties in
            guard let title = properties?.title, let url = properties?.url else { return }
            self.copyAsMarkdown(withTitle: title, url: url)
        }
    }
    
    private func copyAsMarkdown(withTitle title: String, url: URL) {
        
        NSPasteboard.general().clearContents()
        
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)?
            .takeRetainedValue() ?? "" as CFString
        
        if UTTypeConformsTo(uti, kUTTypeImage as CFString) {
            NSPasteboard.general().setString("![\(title)](\(url.absoluteString))", forType: NSPasteboardTypeString)
            
        } else {
            NSPasteboard.general().setString("[\(title)](\(url.absoluteString))", forType: NSPasteboardTypeString)
        }
    }
}
