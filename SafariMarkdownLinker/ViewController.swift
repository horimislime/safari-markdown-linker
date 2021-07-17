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

final class TextFieldCellView: NSView {
    let textField = NSTextField(frame: .zero)
    
    convenience init(string: String) {
        self.init(frame: .zero)
        textField.stringValue = string
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        textField.frame = CGRect(x: 4, y: 4, width: frame.width - 4 * 2, height: frame.height - 4 * 2)
    }
}

protocol CheckBoxCellViewDelegate: AnyObject {
    func checkBoxCellView(_ view: CheckBoxCellView, didUpdateCheckStatus status: Bool)
}

final class CheckBoxCellView: NSView {
    
    weak var delegate: CheckBoxCellViewDelegate?
    
    let checkBox = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkBoxDidChanged(_:)))
    
    convenience init(checked: Bool) {
        self.init(frame: .zero)
        checkBox.state = checked ? .on : .off
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(checkBox)
        checkBox.target = self
        checkBox.action = #selector(checkBoxDidChanged(_:))
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        let boxSize: CGFloat = 24
        checkBox.frame = CGRect(x: (frame.width - boxSize) / 2, y: (frame.height - boxSize) / 2, width: boxSize, height: boxSize)
    }
    
    @objc private func checkBoxDidChanged(_ sender: NSButton) {
        delegate?.checkBoxCellView(self, didUpdateCheckStatus: sender.state == .on)
    }
}

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
    
    @IBOutlet private weak var nameColumn: NSTableColumn!
    @IBOutlet private weak var formatColumn: NSTableColumn!
    @IBOutlet private weak var enabledColumn: NSTableColumn!
    
    private var setting: Setting!
    
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
        urlFormatListTableView.usesAutomaticRowHeights = true
        urlFormatListTableView.rowHeight = 32
        
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                            selector: #selector(handleNotification(_:)),
                                                            name: NSWorkspace.didActivateApplicationNotification,
                                                            object: nil)
        
        if let setting = Setting.load() {
            self.setting = setting
        } else {
            self.setting = Setting.default
            self.setting.save()
        }
        urlFormatListTableView.reloadData()
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
        switch (tableColumn) {
        case nameColumn:
            let field = TextFieldCellView(string: setting.urlFormats[row].name)
            field.textField.delegate = self
            return field
        case formatColumn:
            let field = TextFieldCellView(string: setting.urlFormats[row].pattern)
            field.textField.delegate = self
            return field
        case enabledColumn:
            let cell = CheckBoxCellView(checked: setting.urlFormats[row].isEnabled)
            cell.delegate = self
            return cell
        default:
            preconditionFailure("Table column is illegally configured.")
        }
    }
    
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let setting = setting else { return 0 }
        return setting.urlFormats.count
    }
}

extension ViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let rowNumber = urlFormatListTableView.row(for: control)
        let columnNumber = urlFormatListTableView.column(for: control)
        let editedFormat = setting.urlFormats[rowNumber]
        
        switch columnNumber {
        case 0:
            setting.urlFormats[rowNumber] = URLFormat(
                name: fieldEditor.string,
                pattern: editedFormat.pattern,
                isEnabled: editedFormat.isEnabled,
                commandName: editedFormat.commandName)
        case 1:
            setting.urlFormats[rowNumber] = URLFormat(
                name: editedFormat.name,
                pattern: fieldEditor.string,
                isEnabled: editedFormat.isEnabled,
                commandName: editedFormat.commandName)
        default:
            preconditionFailure()
        }

        setting.save()
        return true
    }
}

extension ViewController: CheckBoxCellViewDelegate {
    func checkBoxCellView(_ view: CheckBoxCellView, didUpdateCheckStatus status: Bool) {
        let rowNumber = urlFormatListTableView.row(for: view)
        let editedFormat = setting.urlFormats[rowNumber]
        setting.urlFormats[rowNumber] = URLFormat(
            name: editedFormat.name,
            pattern: editedFormat.pattern,
            isEnabled: status,
            commandName: editedFormat.commandName)
        setting.save()
    }
}
