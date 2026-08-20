//
//  TabsViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit
import NSObject_Rx
import RxCocoa
import RxSwift
import SnapKit

final class TabsViewController: BaseViewController {
    private let type: TagType
    private let segmentedPageView = SegmentedPageView()
    private lazy var viewModel = TabsViewModel(type: type)

    private var requestedPageIndices: Set<Int> = []
    private var pageViewControllers: [SingleTabListViewController] = []

    init(type: TagType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

private extension TabsViewController {
    func setupUI() {
        title = type.title
        view.backgroundColor = .playAndroidBackground

        //点击item
        segmentedPageView.onSelectedIndex = { [weak self] index in
            self?.requestPageIfNeeded(at: index)
        }
        
        //视图大小
        view.addSubview(segmentedPageView)
        segmentedPageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kTopMargin)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(type.bottomOffset)
        }
    }

    func binding() {
        
        //请求数据
        viewModel.inputs.loadData()
        
        //监听数据
        viewModel.outputs.dataSource
            .asDriver()
            .drive(onNext: { [weak self] tabs in
                self?.updatePages(with: tabs)
            })
            .disposed(by: rx.disposeBag)

        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)

        errorRetry
            .bind(onNext: { [weak self] in
                self?.viewModel.loadData()
            })
            .disposed(by: rx.disposeBag)
    }

    func updatePages(with tabs: [TabModel]) {
        removeCurrentPages()
        guard !tabs.isEmpty else { return }

        //创建子控制器
        pageViewControllers = tabs.map { tab in
            SingleTabListViewController(type: type, tabModel: tab) { [weak self] info in
                self?.pushToWebViewController(webLoadInfo: info)
            }
        }

        pageViewControllers.forEach(addChild)
        segmentedPageView.update(
            titles: tabs.map { $0.name?.replaceHtmlElement ?? "" },
            pageViews: pageViewControllers.map(\.view)
        )
        pageViewControllers.forEach { $0.didMove(toParent: self) }

        requestedPageIndices.removeAll()
        requestPageIfNeeded(at: 0)
    }

    func requestPageIfNeeded(at index: Int) {
        guard pageViewControllers.indices.contains(index),
              requestedPageIndices.insert(index).inserted else { return }
        pageViewControllers[index].requestData()
    }

    func removeCurrentPages() {
        pageViewControllers.forEach { controller in
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
        pageViewControllers.removeAll()
        requestedPageIndices.removeAll()
    }
}
