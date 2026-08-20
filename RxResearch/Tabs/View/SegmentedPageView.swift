//
//  SegmentedPageView.swift
//  RxResearch
//
//  Created by Codex on 2026/8/20.
//

import UIKit

import JXSegmentedView
import SnapKit

/// 可复用的分段分页视图，统一管理标题栏样式、指示器和横向分页容器。
final class SegmentedPageView: UIView {

    var onSelectedIndex: ((Int) -> Void)?

    private let segmentedDataSource = JXSegmentedTitleDataSource()
    private let segmentedView = JXSegmentedView()

    private(set) lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private var pageViews: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutPageViews()
    }

    /// 更新标题和对应的页面视图。两者按下标一一对应。
    func update(titles: [String], pageViews: [UIView], defaultSelectedIndex: Int = 0) {
        precondition(titles.count == pageViews.count, "titles 与 pageViews 数量必须一致")

        self.pageViews.forEach { $0.removeFromSuperview() }
        self.pageViews = pageViews
        pageViews.forEach { contentScrollView.addSubview($0) }

        segmentedDataSource.titles = titles
        segmentedView.defaultSelectedIndex = titles.indices.contains(defaultSelectedIndex)
            ? defaultSelectedIndex
            : 0
        segmentedView.reloadData()

        setNeedsLayout()
        layoutIfNeeded()
    }
}

private extension SegmentedPageView {
    func setupUI() {
        backgroundColor = .playAndroidBackground

        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleNormalColor = .playAndroidTitle
        segmentedDataSource.titleSelectedColor = .systemBlue
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        segmentedView.backgroundColor = .playAndroidBackground

        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.lineStyle = .lengthen
        indicator.indicatorColor = .systemBlue
        segmentedView.indicators = [indicator]
        segmentedView.contentScrollView = contentScrollView

        addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func layoutPageViews() {
        let pageSize = contentScrollView.bounds.size
        guard pageSize.width > 0, pageSize.height > 0 else { return }

        for (index, pageView) in pageViews.enumerated() {
            pageView.frame = CGRect(
                x: pageSize.width * CGFloat(index),
                y: 0,
                width: pageSize.width,
                height: pageSize.height
            )
        }
        contentScrollView.contentSize = CGSize(
            width: pageSize.width * CGFloat(pageViews.count),
            height: pageSize.height
        )
    }
}

extension SegmentedPageView: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        onSelectedIndex?(index)
    }
}
