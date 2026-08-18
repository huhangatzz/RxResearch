//
//  BaseTableViewController.swift
//  RxResearch
//  增加列表页面通用能力
//  Created by Kaiser on 2026/8/12.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx

import MJRefresh
import SnapKit

class BaseTableViewController: BaseViewController {

    //定义平铺的tableView
    lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    //无缓存,能终止,只接收订阅之后的事件
    let emptyDataSetButtonTap = PublishSubject<Void>()
    
    // 不立即处理初始的 `false`，但第一次真实状态变化不会被丢弃。
    let isEmptyRelay = ExBehaviorRelay(value: false, isIgnoreInitValue: true)
    
    //获取所有cell
    static let allClass: [UITableViewCell.Type] = [UITableViewCell.self,
                                                   InfoCell.self]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

extension BaseTableViewController {
    private func setupTableView() {
        /// 注册Cell之后,就可以直接在数据源中进行强制与复用,而不用再写if 与 else了
        _ = BaseTableViewController.allClass.map({ tableView.register($0, forCellReuseIdentifier: $0.className) })
        
        tableView.tableFooterView = UIView()
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        addTableViewAndLayout()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        //刷新
        tableView.mj_header = MJRefreshNormalHeader()
        let footer = MJRefreshAutoNormalFooter()
        footer.setTitle("", for: .idle)
        footer.isRefreshingTitleHidden = true
        footer.triggerAutomaticallyRefreshPercent = -2
        tableView.mj_footer = footer
        
        //设置EmptyDataSet的数据源和代理
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        /// 获取indexPath 基类中取消点击cell的动画效果
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.tableView.deselectRow(at:indexPath, animated: false)
                debugLog(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        /// 订阅点击了数据为空，请重试的行为，里面没有用状态去绑定tableView是因为没有ViewModel
        emptyDataSetButtonTap
            .bind { [weak self] _ in
                self?.tableView.mj_header?.beginRefreshing()
            }
            .disposed(by: rx.disposeBag)
        
        /// 数据为空的订阅
        isEmptyRelay
            .distinctUntilChanged()
            .bind { [weak self] noContent in
                guard let self else { return }
                tableView.reloadEmptyDataSet()
                if noContent {
                    debugLog("监听没有内容")
                    tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension BaseTableViewController {
    private func addTableViewAndLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate
extension BaseTableViewController: UITableViewDelegate {}

//配置空数据占位图
// MARK: - EmptyDataSetSource
extension BaseTableViewController: EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "暂无数据")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "尝试点击刷新获取数据")
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return .clear
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -60
    }
}

// MARK: - EmptyDataSetDelegate
extension BaseTableViewController: EmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return isEmptyRelay.value
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView) {
        emptyDataSetButtonTap.onNext()
    }
}
