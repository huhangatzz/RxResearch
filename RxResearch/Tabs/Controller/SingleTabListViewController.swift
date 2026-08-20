//
//  SingleTabListViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/20.
//

import UIKit
import MJRefresh
import NSObject_Rx
import RxCocoa
import RxSwift

final class SingleTabListViewController: BaseTableViewController {
    private let type: TagType
    private let tabModel: TabModel
    private let cellSelected: ((WebLoadInfo) -> Void)?
    private lazy var viewModel = SingleTabListViewModel(type: type, tabID: tabModel.id ?? 0)

    init(type: TagType, tabModel: TabModel, cellSelected: ((WebLoadInfo) -> Void)? = nil) {
        self.type = type
        self.tabModel = tabModel
        self.cellSelected = cellSelected
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
    }

    /// 由父控制器在该页第一次显示时调用。
    func requestData() {
        viewModel.inputs.loadData(actionType: .refresh)
    }
}

private extension SingleTabListViewController {
    func binding() {
        tableView.mj_header?.rx.refresh
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        tableView.mj_footer?.rx.refresh
            .map { ScrollViewActionType.loadMore }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)

        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)

        errorRetry
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        viewModel.outputs.dataSource
            .map(\.isEmpty)
            .bind(to: isEmptyRelay)
            .disposed(by: rx.disposeBag)

        viewModel.outputs.dataSource
            .asDriver()
            .drive(tableView.rx.items) { tableView, _, info in
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.className) as! InfoCell
                cell.info = info
                return cell
            }
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(Info.self)
            .bind { [weak self] info in
                self?.cellSelected?(info)
            }
            .disposed(by: rx.disposeBag)
    }
}
