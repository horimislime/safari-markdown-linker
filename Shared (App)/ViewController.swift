//
//  ViewController.swift
//  URLLinker
//
//  Created by horimislime on 2017/09/10.
//  Copyright © 2017 horimislime. All rights reserved.
//

import Cocoa
import SafariServices

private let extensionIdentifier = "\(Bundle.main.bundleIdentifier!).SafariExtension"

final class TextFieldCellView: NSView {
    let textField: NSTextField = {
        let field = NSTextField(frame: .zero)
        field.drawsBackground = false
        field.isBezeled = false
        field.cell?.usesSingleLineMode = true
        field.cell?.lineBreakMode = .byTruncatingTail
        return field
    }()
    
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
        let spacing: CGFloat = 2
        textField.frame = CGRect(x: spacing, y: spacing, width: frame.width - spacing * 2, height: frame.height - spacing * 2)
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
    
    var image: NSImage {
        switch self {
        case .enabled: return NSImage(named: NSImage.statusAvailableName)!
        case .disabled, .unknown(_): return NSImage(named: NSImage.statusUnavailableName)!
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

final class ViewController: NSViewController {
    
    @IBOutlet private weak var statusIconImageView: NSImageView!
    @IBOutlet private weak var extensionStatusText: NSTextField!
    @IBOutlet private weak var urlFormatListTableView: NSTableView!
    @IBOutlet private weak var segmentedControl: NSSegmentedControl!
    @IBOutlet private weak var nameColumn: NSTableColumn!
    @IBOutlet private weak var formatColumn: NSTableColumn!
    @IBOutlet private weak var enabledColumn: NSTableColumn!
    
    private var setting: Setting!
    
    private func updateView(withStatus status: ExtensionStatus) {
        DispatchQueue.main.async {
            self.statusIconImageView.image = status.image
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
        urlFormatListTableView.rowHeight = 24
        
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(handleNotification(_:)),
                                                          name: NSWorkspace.didActivateApplicationNotification,
                                                          object: nil)
        
        if let setting = Setting.load() {
            self.setting = setting
        } else {
            setting = Setting.default
            setting.save()
        }
        urlFormatListTableView.reloadData()
        segmentedControl.target = self
        segmentedControl.action = #selector(handleSegmentedControlClicked(_:))
        updateSegmentedControlState()
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        if NSRunningApplication.current.isActive {
            getExtensionState()
        }
    }
    
    @IBAction private func openExtensionButtonClicked(_ sender: NSButton) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionIdentifier) { _ in }
    }
    
    @objc private func handleSegmentedControlClicked(_ sender: NSSegmentedCell) {
        switch sender.selectedSegment {
        case 0:
            setting.addFormat(name: "Sample", pattern: "Title: %TITLE, URL: %URL")
        case 1:
            for i in urlFormatListTableView.selectedRowIndexes {
                setting.urlFormats.remove(at: i)
            }
        default:
            preconditionFailure()
        }
        setting.save()
        urlFormatListTableView.reloadData()
        updateSegmentedControlState()
    }
    
    private func updateSegmentedControlState() {
        segmentedControl.setEnabled(urlFormatListTableView.numberOfRows < 5, forSegment: 0)
        segmentedControl.setEnabled(urlFormatListTableView.numberOfSelectedRows > 0, forSegment: 1)
    }
}

// MARK: - NSTableViewDelegate

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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateSegmentedControlState()
    }
}

// MARK: - NSTableViewDataSource

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let setting = setting else { return 0 }
        return setting.urlFormats.count
    }
}

// MARK: - NSTextFieldDelegate

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

// MARK: - CheckBoxCellViewDelegate

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
