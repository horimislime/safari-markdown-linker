//
//  ViewController.swift
//  SafariMarkdownLinker
//
//  Created by horimislime on 2017/09/10.
//  Copyright © 2017 horimislime. All rights reserved.
//

import Cocoa
import SafariServices

private let extensionIdentifier = "\(Bundle.main.bundleIdentifier!).SafariExtension"

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
    
    @IBOutlet weak var urlFormatListTableView: NSTableView!
    
    private let nameColumn: NSTableColumn = {
        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "name_column"))
        nameColumn.title = "Name"
        return nameColumn
    }()
    private let formatColumn: NSTableColumn = {
        let formatColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "format_column"))
        formatColumn.title = "URL Format"
        return formatColumn
    }()
    
    private func updateView(withStatus status: ExtensionStatus) {
        DispatchQueue.main.async {
            self.extensionStatusIcon.stringValue = status.icon
            self.extensionStatusText.stringValue = status.text
        }
    }
    
    private func getExtensionState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionIdentifier) { [weak self] state, error in
            
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
    
    override func viewWillAppear() {
        super.viewWillAppear()
        getExtensionState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlFormatListTableView.delegate = self
        urlFormatListTableView.dataSource = self
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                            selector: #selector(handleNotification(_:)),
                                                            name: NSWorkspace.didActivateApplicationNotification,
                                                            object: nil)
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    @objc func handleNotification(_ notification: Notification) {
        if NSRunningApplication.current.isActive {
            getExtensionState()
        }
    }
    
    @IBAction func openExtensionButtonClicked(_ sender: NSButton) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionIdentifier) { _ in }
    }
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = NSTableCellView(frame: .init(x: 0, y: 0, width: 100, height: 50))
        cell.textField?.stringValue = "hogehoge"
        return cell
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        2
    }
}
