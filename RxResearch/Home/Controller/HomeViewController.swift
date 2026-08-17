//
//  HomeViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit

import RxSwift
import RxSwiftExt
import RxCocoa
import NSObject_Rx

import MJRefresh

class HomeViewController: BaseTableViewController {
    
    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension HomeViewController {
    private func setupUI() {
        title = "首页"
        tableView.estimatedRowHeight = 88
    }
    
    private func binding() {
        //刷新头部
        tableView.mj_header?.rx.refresh
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)//onNext: 交给一个方法处理
            .disposed(by: rx.disposeBag)
        
        //刷新尾部
        tableView.mj_footer?.rx.refresh
            .map { ScrollViewActionType.loadMore }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        //处理错误图的点击重试
        errorRetry
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        // 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, _, info) in
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.className) as! InfoCell
                cell.info = info
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        //监听数据是否为空
        viewModel.outputs.dataSource
            .map { $0.isEmpty }
            .bind(to: isEmptyRelay)//to 传递给另一个Observer
            .disposed(by: rx.disposeBag)
        
        //控制错误图显示与隐藏
        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
        
        /// 首次加载直接请求并由全局 HUD 反馈，不触发下拉动画。
        viewModel.inputs.loadData(actionType: .refresh)
    }
}

//app第一次安装时获取网络权限后刷新数据
extension HomeViewController : TabBarVCChildrenRefreshProtocol {
    func dataRefresh() {
        debugLog("\(className) dataRefresh")
        viewModel.inputs.loadData(actionType: .refresh)
    }
}
