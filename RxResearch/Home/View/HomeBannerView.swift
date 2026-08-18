//
//  HomeBannerView.swift
//  RxResearch
//
//  Created by Codex on 2026/8/18.
//

import UIKit

import RxSwift
import RxCocoa
import FSPagerView
import Kingfisher
import SnapKit

final class HomeBannerView: UIView {
    
    //点击事件
    var onSelectBanner: ((Banner) -> Void)?

    //数组
    private var banners: [Banner] = [] {
        didSet {
            pageControl.numberOfPages = banners.count
            pageControl.currentPage = 0
            pagerView.reloadData()
        }
    }

    private lazy var pagerView: FSPagerView = {
        let pagerView = FSPagerView()
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.className)
        pagerView.automaticSlidingInterval = 3
        pagerView.isInfinite = true
        return pagerView
    }()

    private let pageControl: FSPageControl = {
        let pageControl = FSPageControl()
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        return pageControl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(pagerView)
        pagerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
    }

    fileprivate func update(banners: [Banner]) {
        self.banners = banners
    }
}

// MARK: - FSPagerViewDataSource
extension HomeBannerView: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        banners.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.className, at: index)
        cell.imageView?.kf.cancelDownloadTask()
        cell.imageView?.image = nil

        if let imagePath = banners[index].imagePath,
           let url = URL(string: imagePath) {
            cell.imageView?.kf.setImage(with: url,
                options: [
                    .transition(.fade(0.25)),
                    .scaleFactor(traitCollection.displayScale),
                    .cacheSerializer(FormatIndicatedCacheSerializer.png)
                ]
            )
        }
        return cell
    }
}

// MARK: - FSPagerViewDelegate
extension HomeBannerView: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        guard banners.indices.contains(index) else { return }
        
        onSelectBanner?(banners[index])
    }

    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        pageControl.currentPage = index
    }
}

//使用这种方法给封装的视图传递数据
extension Reactive where Base: HomeBannerView {
    var banners: Binder<[Banner]> {
        Binder(base) { bannerView, banners in
            bannerView.update(banners: banners)
        }
    }
}
