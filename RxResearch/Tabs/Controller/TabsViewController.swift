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

    /// 只保存已经展示过的页面，避免启动时一次创建全部子控制器和 TableView。
    private var pageViewControllers: [Int: SingleTabListViewController] = [:]
    private var pageContainers: [UIView] = []
    private var tabs: [TabModel] = []

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
            self?.showPageIfNeeded(at: index)
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

        self.tabs = tabs
        // 分页组件只持有轻量容器；真正的控制器在页面第一次显示时创建。
        pageContainers = tabs.map { _ in UIView() }
        segmentedPageView.update(
            titles: tabs.map { $0.name?.replaceHtmlElement ?? "" },
            pageViews: pageContainers
        )
        showPageIfNeeded(at: 0)
    }

    func showPageIfNeeded(at index: Int) {
        guard tabs.indices.contains(index),
              pageContainers.indices.contains(index),
              pageViewControllers[index] == nil else { return }

        let controller = SingleTabListViewController(
            type: type,
            tabModel: tabs[index]
        ) { [weak self] info in
            self?.pushToWebViewController(webLoadInfo: info)
        }

        let container = pageContainers[index]
        addChild(controller)
        container.addSubview(controller.view)
        controller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        controller.didMove(toParent: self)
        pageViewControllers[index] = controller
        controller.requestData()
    }

    func removeCurrentPages() {
        pageViewControllers.values.forEach { controller in
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
        pageViewControllers.removeAll()
        pageContainers.removeAll()
        tabs.removeAll()
    }
}
