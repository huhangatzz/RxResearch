//
//  HomeViewController.swift
//  RxResearch
//  它本身不负责请求和处理数据，主要负责“接线”。可以把它理解为一个配电箱：UI 操作 → ViewModel 输入 ViewModel 输出 → UI
//  binding() 里面一共有 7 条主要线路。
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
    
    //轮播图
    private lazy var bannerView: HomeBannerView = {
        let width = view.bounds.width
        let bannerView = HomeBannerView(frame: CGRect(x: 0, y: 0, width: width, height: width / 16 * 9))
        bannerView.onSelectBanner = { banner in
            debugLog("点击了轮播图的\(banner)")
            // pushToWebViewController(webLoadInfo: banner, isNeedShowCollection: false)
        }
        return bannerView
    }()

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
        tableView.tableHeaderView = bannerView
    }
    
    private func binding() {
        //线路 1：下拉刷新
        tableView.mj_header?.rx.refresh//用户下拉
            .map { ScrollViewActionType.refresh }//转成 .refresh
            .bind(onNext: viewModel.inputs.loadData)//onNext: 交给一个方法处理,调用loadData方法
            .disposed(by: rx.disposeBag)
        
        //线路 2：上拉加载更多
        tableView.mj_footer?.rx.refresh //用户上拉到底部
            .map { ScrollViewActionType.loadMore } //转成 .loadMore
            .bind(onNext: viewModel.inputs.loadData)//
            .disposed(by: rx.disposeBag)
        
        //线路 3：点击错误图重试
        errorRetry //发出 Void
            .map { ScrollViewActionType.refresh }//转成 .refresh
            .bind(onNext: viewModel.inputs.loadData)//调用loadData方法
            .disposed(by: rx.disposeBag)
        
        // 线路 4：数据展示
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])//如果上游错误，则使用空数组
            .drive(tableView.rx.items) { (tableView, _, info) in //Driver 适合 UI 绑定
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.className) as! InfoCell
                cell.info = info
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        //线路 5：判断空数据
        viewModel.outputs.dataSource //同一个 dataSource 有两个消费者
            .map { $0.isEmpty }//转换成 Bool，控制空数据页
            .bind(to: isEmptyRelay)//to 传递给另一个Observer
            .disposed(by: rx.disposeBag)
        
        //线路 6：控制网络错误图
        viewModel.outputs.networkError//是否发送错误，是 HomeViewModel 决定的
            .bind(to: rx.networkError)//不负责判断是否应该显示，只负责执行显示结果
            .disposed(by: rx.disposeBag)
        
        //线路 7：控制刷新控件状态
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
        
        /// 轮播图数据驱动
        viewModel.outputs.banners
            .bind(to: bannerView.rx.banners)
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
