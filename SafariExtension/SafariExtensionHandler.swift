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
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        
        NSPasteboard.general().clearContents()
        
        if let title = lastLinkDetail?["title"] as? String, let urlString = lastLinkDetail?["url"] as? String {
            NSPasteboard.general().setString("![\(title)](\(urlString))", forType: NSPasteboardTypeString)
            return
        }
        
        page.getPropertiesWithCompletionHandler { properties in
            
            guard let title = properties?.title, let url = properties?.url else { return }
            
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)?
                .takeRetainedValue() ?? "" as CFString
            
            if UTTypeConformsTo(uti, kUTTypeImage as CFString) {
                NSPasteboard.general().setString("![\(title)](\(url.absoluteString))", forType: NSPasteboardTypeString)
                
            } else {
                NSPasteboard.general().setString("[\(title)](\(url.absoluteString))", forType: NSPasteboardTypeString)
            }
        }
    }
}
