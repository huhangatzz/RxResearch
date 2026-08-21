//
//  TreeTagCell.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/21.
//

import UIKit

final class TreeTagCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .random
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.addSubview(titleLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
    }

    func configure(title: String?) {
        titleLabel.text = title
    }
}

/// UICollectionViewFlowLayout 默认会拉伸一行中的 item 间距以填满宽度。
/// 体系标签需要固定间距，因此将每行元素依次向左排列。
final class TreeLeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var left = sectionInset.left
        var currentRowY: CGFloat = -.greatestFiniteMagnitude

        attributes
            .filter { $0.representedElementCategory == .cell }
            .forEach { attribute in
                if abs(attribute.frame.minY - currentRowY) > 1 {
                    currentRowY = attribute.frame.minY
                    left = sectionInset.left
                }

                attribute.frame.origin.x = left
                left = attribute.frame.maxX + minimumInteritemSpacing
            }

        return attributes
    }
}
