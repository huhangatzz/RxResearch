//
//  SearchResultController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import MJRefresh


class SearchResultController: BaseTableViewController {

    private let keyword: String

    init(keyword: String) {
        self.keyword = keyword
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        binding()
    }
}

extension SearchResultController {
    private func setupUI() {
        title = keyword
    }
    
    private func binding() {
        let viewModel = SearchResultViewModel(keyword: keyword)
        
        //获取接口数据
        viewModel.inputs.loadData(actionType: .refresh)
        
        // ---------------  列表必写  --------------- //
        tableView.mj_header?.rx.refresh
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        tableView.mj_footer?.rx.refresh
            .map { ScrollViewActionType.loadMore }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        //下拉与上拉状态绑定到tableView
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
        
        //监听网络错误
        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)
        
        //点击错误
        errorRetry
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        //监听空数据
        viewModel.outputs.dataSource
            .map { $0.isEmpty }
            .bind(to: isEmptyRelay)
            .disposed(by: rx.disposeBag)
        
        
        // ---------------  数据处理  --------------- //
        //绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView,_,info) in
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.className) as! InfoCell
                cell.info = info
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        //点击cell
        tableView.rx.modelSelected(Info.self)
            .subscribe { [weak self] model in
                guard let self else { return }
                self.pushToWebViewController(webLoadInfo: model)
            }
            .disposed(by: rx.disposeBag)
    }
}
