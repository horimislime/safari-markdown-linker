//
//  AppDelegate.swift
//  SafariMarkdownLinker
//
//  Created by horimislime on 2017/09/10.
//  Copyright © 2017 horimislime. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let window = NSApplication.shared.keyWindow {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.title = Bundle.main.infoDictionary!["CFBundleName"] as! String
        }
    }
}
