//
//  SafariExtensionHandler.swift
//  SafariExtension
//
//  Created by horimislime on 2017/09/10.
//  Copyright © 2017 horimislime. All rights reserved.
//

import AppKit
import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
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
        
        page.getPropertiesWithCompletionHandler { properties in
            
            guard let title = properties?.title, let url = properties?.url else { return }
            
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)?
                .takeRetainedValue() ?? "" as CFString
            
            NSPasteboard.general().clearContents()
            if UTTypeConformsTo(uti, kUTTypeImage as CFString) {
                NSPasteboard.general().setString("![\(title)](\(url.absoluteString))", forType: NSPasteboardTypeString)
                
            } else {
                NSPasteboard.general().setString("[\(title)](\(url.absoluteString))", forType: NSPasteboardTypeString)
            }
        }
    }
}
