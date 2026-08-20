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
    
    // 忽略数据源 BehaviorRelay 绑定过来的第一次初始值 []，
    // 首次网络结果返回前不展示空数据页。
    let isEmptyRelay = ExBehaviorRelay(
        value: false,
        isIgnoreInitValue: true,
        isIgnoreFirstAccept: true
    )
    
    //添加所有使用的cell
    static let allClass: [UITableViewCell.Type] = [UITableViewCell.self,
                                                   InfoCell.self ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlainTableView()
        baseTableBinding()
    }
}

extension BaseTableViewController {
    private func setupPlainTableView() {
        tableView.tableFooterView = UIView()
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        //设置EmptyDataSet的数据源和代理
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        //刷新
        tableView.mj_header = MJRefreshNormalHeader()
        let footer = MJRefreshAutoNormalFooter()
        footer.setTitle("上拉加载更多", for: .idle)
        footer.setTitle("正在加载更多...", for: .refreshing)
        footer.isRefreshingTitleHidden = false
        footer.triggerAutomaticallyRefreshPercent = -2
        // 首次请求结果返回前没有可加载的列表内容，Footer 默认隐藏。
        footer.isHidden = true
        tableView.mj_footer = footer
        
        //布局表格视图
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        /// 注册Cell之后,就可以直接在数据源中进行强制与复用,而不用再写if 与 else了
        BaseTableViewController.allClass.forEach {
            tableView.register($0, forCellReuseIdentifier: $0.className)
        }
    }

    private func baseTableBinding() {
        /// 基类中取消点击cell的动画效果
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.tableView.deselectRow(at:indexPath, animated: false)
                debugLog(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        /// 数据为空的订阅
        isEmptyRelay
            .distinctUntilChanged()
            .bind { [weak self] noContent in
                guard let self else { return }

                // 空数据只控制占位图和 Footer 显隐；分页状态由 refreshSubject 控制。
                tableView.mj_footer?.isHidden = noContent
                tableView.reloadEmptyDataSet()

                if noContent {
                    debugLog("监听没有内容")
                }
            }
            .disposed(by: rx.disposeBag)
        
        /// 订阅点击了数据为空，请重试的行为
        emptyDataSetButtonTap
            .bind { [weak self] _ in
                self?.tableView.mj_header?.beginRefreshing()
            }
            .disposed(by: rx.disposeBag)
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
