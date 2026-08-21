//
//  MessageCell.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/21.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MessageCell: UITableViewCell {
    
    private var _count: Int!

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 11
        label.textColor = .white
        label.backgroundColor = .red
        return label
    }()
    
    var count: Int {
        set {
            _count = newValue
            countLabel.text = newValue > 99 ? "99+" : newValue.toString
            countLabel.isHidden = !newValue.greaterThanZero
        }
        
        get {
            return _count
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageCell {
    private func setupUI() {
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
}

extension Reactive where Base == MessageCell {
    var count: Binder<Int> {
        return Binder(base) { cell, count in
            cell.count = count
        }
    }
}
