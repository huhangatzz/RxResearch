//
//  TreeCell.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/20.
//

import UIKit

/// 换行模式下的体系 Cell。
/// 使用可复用的 CollectionViewCell 展示标签，避免每次刷新创建一批 UIButton 和 Rx 订阅。
final class TreeCell: UITableViewCell {
    var onSelect: ((TabModel) -> Void)?

    private enum Layout {
        static let horizontalInset: CGFloat = 12
        static let topInset: CGFloat = 2
        static let bottomInset: CGFloat = 6
        static let itemHeight: CGFloat = 30
        static let horizontalSpacing: CGFloat = 12
        static let verticalSpacing: CGFloat = 6
        static let horizontalTextPadding: CGFloat = 20
    }

    private var children: [TabModel] = []

    private lazy var collectionView: UICollectionView = {
        let layout = TreeLeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = Layout.horizontalSpacing
        layout.minimumLineSpacing = Layout.verticalSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Layout.topInset,
            left: Layout.horizontalInset,
            bottom: Layout.bottomInset,
            right: Layout.horizontalInset
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TreeTagCell.self, forCellWithReuseIdentifier: TreeTagCell.className)
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(collectionView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSelect = nil
        children.removeAll()
        collectionView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: preferredHeight(for: size.width))
    }

    func configure(with model: TabModel) {
        children = model.children ?? []
        collectionView.reloadData()
    }
}

private extension TreeCell {
    func itemWidth(for model: TabModel) -> CGFloat {
        let textWidth = ((model.name ?? "") as NSString).size(
            withAttributes: [.font: UIFont.systemFont(ofSize: 15)]
        ).width
        return ceil(textWidth) + Layout.horizontalTextPadding
    }

    func preferredHeight(for width: CGFloat) -> CGFloat {
        guard !children.isEmpty else { return 0 }

        let availableWidth = max(0, width - Layout.horizontalInset * 2)
        var rowCount = 1
        var usedWidth: CGFloat = 0

        children.forEach { model in
            let width = min(itemWidth(for: model), availableWidth)
            let requiredWidth = usedWidth == 0 ? width : Layout.horizontalSpacing + width
            if usedWidth > 0, usedWidth + requiredWidth > availableWidth {
                rowCount += 1
                usedWidth = width
            } else {
                usedWidth += requiredWidth
            }
        }

        return Layout.topInset + Layout.bottomInset
            + CGFloat(rowCount) * Layout.itemHeight
            + CGFloat(rowCount - 1) * Layout.verticalSpacing
    }
}

extension TreeCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        children.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TreeTagCell.className,
            for: indexPath
        ) as! TreeTagCell
        cell.configure(title: children[indexPath.item].name)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = max(0, collectionView.bounds.width - Layout.horizontalInset * 2)
        return CGSize(
            width: min(itemWidth(for: children[indexPath.item]), availableWidth),
            height: Layout.itemHeight
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(children[indexPath.item])
    }
}
