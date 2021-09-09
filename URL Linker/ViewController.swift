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
        label.text =
"""
        You can define format to copy page URL and title.
        Within URL format, you can put %TITLE and %URL, these value will be replaced to title and URL.
"""
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.bounds
    }
}

class ViewController: UITableViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "URL Linker"
        let header = TableHeaderView()
        header.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Format"
    }
}
