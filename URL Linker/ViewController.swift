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
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UITableViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "URL Linker"
        let header = TableHeaderView()
        tableView.tableHeaderView = header
        header.layoutIfNeeded()
        tableView.tableHeaderView = header
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(handleAddButton))
    }
    
    @objc private func handleAddButton() {
        let vc = AddFormatViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

final class AddFormatViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Format"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close,
                                                            target: self,
                                                            action: #selector(handleDoneButton))
        
        view.addSubview(tableView)
        configure()
    }
    
    func configure() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func handleDoneButton() {
        dismiss(animated: true)
    }
}
