//
//  ViewController.swift
//  URL Linker
//
//  Created by horimislime on 2021/09/07.
//  Copyright © 2021 horimislime. All rights reserved.
//

import UIKit

final class TableHeaderView: UITableViewHeaderFooterView {
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let userDefaults = UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier!)")!
    private var setting: Setting!
    private var cells: [UITableViewCell] = []
    private let headerView: TableHeaderView = {
        let view = TableHeaderView()
        view.label.text = "You can define format to copy page URL and title."
        return view
    }()
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.allowsMultipleSelectionDuringEditing = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "URL Linker"
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                                            target: self, action: #selector(handleAddButton))
        loadSetting()
        configureTableView()
        reloadCells()
        tableView.reloadData()
    }
    
    private func configureTableView() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: tableView.topAnchor),
            headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        ])
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
    }
    
    private func loadSetting() {
        if let savedSetting = Setting.load(from: userDefaults) {
            setting = savedSetting
        } else {
            let defaultSetting = Setting.default
            setting = defaultSetting
            setting.save(to: userDefaults)
        }
    }

    private func reloadCells() {
        cells = setting.urlFormats.map {
            let cell = UITableViewCell()
            cell.textLabel?.text = $0.name
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    @objc private func handleAddButton() {
        presentEditingView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentEditingView(for: setting.urlFormats[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
            self.setting.removeFormat(atIndex: indexPath.row)
            self.setting.save(to: self.userDefaults)
            self.reloadCells()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    private func presentEditingView(for format: URLFormat? = nil) {
        let vc = AddFormatViewController(format: format)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func dismissEditingView() {
        dismiss(animated: true) {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
}

extension ViewController: AddFormatViewControllerDelegate {
    func addFormatViewController(_ controller: AddFormatViewController, didCreateFormat format: URLFormat) {
        setting.addFormat(format)
        setting.save(to: userDefaults)
        reloadCells()
        tableView.reloadData()
        dismissEditingView()
    }
    
    func addFormatViewController(_ controller: AddFormatViewController, didEditFormat format: URLFormat) {
        setting.updateFormat(format)
        setting.save(to: userDefaults)
        reloadCells()
        tableView.reloadData()
        dismissEditingView()
    }
    
    func addFormatViewControllerDidClose(_ controller: AddFormatViewController) {
        dismissEditingView()
    }
}

final class TextFieldCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: UITextField = {
        let field = UITextField(frame: .zero)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        return field
    }()
    
    init() {
        self.init(frame: .zero)
        configure()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.widthAnchor.constraint(equalToConstant: 64),
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
}

protocol AddFormatViewControllerDelegate: NSObject {
    func addFormatViewController(_ controller: AddFormatViewController, didCreateFormat setting: URLFormat)
    func addFormatViewController(_ controller: AddFormatViewController, didEditFormat setting: URLFormat)
    func addFormatViewControllerDidClose(_ controller: AddFormatViewController)
}

final class AddFormatViewController: UIViewController {
    
    weak var delegate: AddFormatViewControllerDelegate?
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    private let headerView: TableHeaderView = {
        let view = TableHeaderView()
        view.label.text = """
You can use %TITLE and %URL variables, these value will be replaced to web page's title and URL.
i.e., Markdown style format can be described as `[%TITLE](%URL)`
"""
        return view
    }()
    
    private let formatNameCell: TextFieldCell = {
        let cell = TextFieldCell()
        cell.selectionStyle = .none
        cell.titleLabel.text = "Name"
        cell.textField.placeholder = "Format Name"
        return cell
    }()
    private let formatPatternCell: TextFieldCell = {
        let cell = TextFieldCell()
        cell.selectionStyle = .none
        cell.titleLabel.text = "Format"
        cell.textField.placeholder = "[%TITLE](%URL)"
        return cell
    }()
    
    private lazy var cells = [formatNameCell, formatPatternCell]
    private lazy var cancelNavigationButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelButton))
    private lazy var doneNavigationButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Done",
                                    style: .done,
                                    target: self,
                                    action: #selector(handleDoneButton))
        button.isEnabled = false
        return button
    }()
    
    private let initialFormat: URLFormat?
    
    init(format: URLFormat? = nil) {
        initialFormat = format
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = initialFormat == nil ? "Add Format" : "Edit Format"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = cancelNavigationButton
        navigationItem.rightBarButtonItem = doneNavigationButton
        
        view.addSubview(tableView)
        configureTableView()
    }
    
    private func configureTableView() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 24
        tableView.dataSource = self
        
        formatNameCell.textField.delegate = self
        formatPatternCell.textField.delegate = self
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: tableView.topAnchor),
            headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        ])
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
        
        guard let format = initialFormat else { return }
        formatNameCell.textField.text = format.name
        formatPatternCell.textField.text = format.pattern
    }
    
    private func updateDoneButtonState() {
        doneNavigationButton.isEnabled = !(formatNameCell.textField.text ?? "").isEmpty && !(formatPatternCell.textField.text ?? "").isEmpty
    }
    
    @objc private func handleCancelButton() {
        delegate?.addFormatViewControllerDidClose(self)
    }
    
    @objc private func handleDoneButton() {
        guard let name = formatNameCell.textField.text, let pattern = formatPatternCell.textField.text else { preconditionFailure() }
        let format = URLFormat(name: name, pattern: pattern, isEnabled: true, commandName: "")
        if initialFormat == nil {
            delegate?.addFormatViewController(self, didCreateFormat: format)
        } else {
            delegate?.addFormatViewController(self, didEditFormat: format)
        }
    }
}

extension AddFormatViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateDoneButtonState()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateDoneButtonState()
    }
}

extension AddFormatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }
}
