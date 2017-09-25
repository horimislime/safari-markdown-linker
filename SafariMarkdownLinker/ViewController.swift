//
//  ViewController.swift
//  SafariMarkdownLinker
//
//  Created by horimislime on 2017/09/10.
//  Copyright © 2017 horimislime. All rights reserved.
//

import Cocoa
import SafariServices

enum ExtensionStatus {
    
    case enabled
    case disabled
    case unknown(NSError)
    
    var icon: String {
        switch self {
        case .enabled: return "✅"
        case .disabled, .unknown(_): return "❌"
        }
    }
    
    var text: String {
        switch self {
        case .enabled: return "Extension is enabled."
        case .disabled: return "Extension is not enabled."
        case .unknown(let error): return "Unknown status. (\(error.localizedDescription))"
        }
    }
}


class ViewController: NSViewController {

    @IBOutlet weak var extensionStatusIcon: NSTextField!
    @IBOutlet weak var extensionStatusText: NSTextField!
    
    private func updateView(withStatus status: ExtensionStatus) {
        DispatchQueue.main.async {
            self.extensionStatusIcon.stringValue = status.icon
            self.extensionStatusText.stringValue = status.text
        }
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "\(Bundle.main.bundleIdentifier!).SafariExtension") { [weak self] state, error in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.updateView(withStatus: .unknown(error as NSError))
                return
            }
            
            if let state = state, state.isEnabled {
                strongSelf.updateView(withStatus: .enabled)
            } else {
                strongSelf.updateView(withStatus: .disabled)
            }
        }
    }
    
    @IBAction func openExtensionButtonClicked(_ sender: NSButton) {
    }
}

