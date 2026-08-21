//
//  LogoutCell.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/21.
//

import UIKit
import SnapKit

class LogoutCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogoutCell {
    private func setupUI() {
        textLabel?.textAlignment = .center
        textLabel?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
