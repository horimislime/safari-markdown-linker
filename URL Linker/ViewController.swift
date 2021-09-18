//
//  ViewController.swift
//  URL Linker
//
//  Created by horimislime on 2021/09/07.
//  Copyright © 2021 horimislime. All rights reserved.
//

import UIKit
import WebKit

class TableHeaderView: UITableViewHeaderFooterView {
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.text =
"""
        You can define format to copy page URL and title.
        Within URL format, you can put %TITLE and %URL, these value will be replaced to title and URL.
"""
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UITableViewController {
    
    private var setting: Setting!
    private var cells: [UITableViewCell] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "URL Linker"
        let header = TableHeaderView()
        tableView.tableHeaderView = header
        header.layoutIfNeeded()
        tableView.tableHeaderView = header
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(handleAddButton))
        
        reloadCells()
        tableView.reloadData()
    }
    
    private func reloadCells() {
        setting = Setting.load() ?? Setting.default
        cells = setting.urlFormats.map {
            let cell = UITableViewCell()
            cell.textLabel?.text = $0.name
            return cell
        }
    }
    
    @objc private func handleAddButton() {
        presentEditingView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentEditingView(for: setting.urlFormats[indexPath.row])
    }
    
    private func presentEditingView(for format: URLFormat? = nil) {
        let vc = AddFormatViewController(format: format)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension ViewController: AddFormatViewControllerDelegate {
    func addFormatViewController(_ controller: AddFormatViewController, didFinishEditingFormat format: URLFormat) {
        dismiss(animated: true)
    }
    
    func addFormatViewControllerDidClose(_ controller: AddFormatViewController) {
        dismiss(animated: true)
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
    func addFormatViewController(_ controller: AddFormatViewController, didFinishEditingFormat setting: URLFormat)
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
    
    private let formatNameCell: TextFieldCell = {
        let cell = TextFieldCell()
        cell.titleLabel.text = "Name"
        return cell
    }()
    private let formatPatternCell: TextFieldCell = {
        let cell = TextFieldCell()
        cell.titleLabel.text = "Format"
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
        title = "Add Format"
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
        delegate?.addFormatViewController(self, didFinishEditingFormat: format)
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
