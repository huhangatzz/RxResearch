//
//  TreeViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

import MJRefresh

final class TreeViewController: BaseTableViewController {
    private typealias TreeSection = SectionModel<TabModel, TabModel>

    private let type: TagType
    private lazy var viewModel = TreeViewModel(type: type)
    private let sections = BehaviorRelay<[TreeSection]>(value: [])
    private var tabs: [TabModel] = []

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<TreeSection>(
        configureCell: { [weak self] dataSource, tableView, indexPath, item in
            guard let self else { return UITableViewCell() }

            switch AccountManager.shared.layoutType {
            case .list:
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = item.name
                cell.textLabel?.font = .systemFont(ofSize: 15)
                cell.accessoryType = .disclosureIndicator
                return cell

            case .wrap:
                let cell = tableView.dequeueReusableCell(withIdentifier: TreeCell.className) as! TreeCell
                cell.configure(with: dataSource.sectionModels[indexPath.section].model)
                cell.onSelect = { [weak self] tab in
                    self?.showArticles(for: tab)
                }
                return cell
            }
        },
        titleForHeaderInSection: { dataSource, section in
            dataSource.sectionModels[section].model.name
        }
    )

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
        viewModel.loadData()
    }
}

private extension TreeViewController {
    func setupUI() {
        title = type.title
        tableView.mj_footer = nil
        tableView.separatorStyle = .none
        // 首屏留白应随内容一起滚走，不能使用 contentInset，否则悬浮标题顶部会出现透明缝隙。
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 4)
        )
        // 压缩系统分区标题高度，减少标题与第一行 Item 之间的空白。
        tableView.sectionHeaderHeight = 30
        tableView.estimatedSectionHeaderHeight = 30
    }

    func binding() {
        tableView.mj_header?.rx.refresh
            .bind(onNext: viewModel.loadData)
            .disposed(by: rx.disposeBag)

        viewModel.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)

        viewModel.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)

        errorRetry
            .bind(onNext: viewModel.loadData)
            .disposed(by: rx.disposeBag)

        viewModel.dataSource
            .asDriver()
            .drive(onNext: { [weak self] tabs in
                self?.apply(tabs: tabs)
            })
            .disposed(by: rx.disposeBag)

        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(TabModel.self)
            .bind { [weak self] tab in
                guard AccountManager.shared.layoutType == .list else { return }
                self?.showArticles(for: tab)
            }
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx.notification(.Layout.typeChange)
            .bind { [weak self] _ in
                self?.rebuildSections()
            }
            .disposed(by: rx.disposeBag)
    }

    func apply(tabs: [TabModel]) {
        self.tabs = tabs.filter { $0.children?.isNotEmpty == true }
        let children = self.tabs.flatMap { $0.children ?? [] }
        isEmptyRelay.accept(children.isEmpty)
        rebuildSections()
    }

    func rebuildSections() {
        let result = tabs.map { tab -> TreeSection in
            let items: [TabModel]
            switch AccountManager.shared.layoutType {
            case .list:
                items = tab.children ?? []
            case .wrap:
                // 换行模式每个 section 只需要一个承载 CollectionView 的 Cell。
                items = [tab]
            }
            return TreeSection(model: tab, items: items)
        }
        sections.accept(result)
    }

    func showArticles(for tab: TabModel) {
        let controller = SingleTabListViewController(type: type, tabModel: tab) { [weak self] info in
            self?.pushToWebViewController(webLoadInfo: info)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension TreeViewController: TabBarVCChildrenRefreshProtocol {
    func dataRefresh() {
        debugLog("\(className) dataRefresh")
        viewModel.loadData()
    }
}
