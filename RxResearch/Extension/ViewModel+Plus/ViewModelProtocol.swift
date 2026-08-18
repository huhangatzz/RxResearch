//
//  ViewModelProtocol.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/13.
//

import Foundation

import RxSwift
import RxCocoa

/// 上下拉行为类型
enum ScrollViewActionType {
    case refresh
    case loadMore
}

/// vm接受页面输入行为
protocol VMInputs {
    /// 加载数据
    /// - Parameter actionType: 操作行为
    func loadData(actionType: ScrollViewActionType)
}

/// vm输出数据行为
protocol VMOutputs {
    associatedtype T
    var dataSource: BehaviorRelay<T> { get }
}

protocol PageVMBaseSetting {
    /// 页码数
    var pageNum: Int { get set }
    
    /// 重置刷新状态与页码数
    func resetCurrentPageAndMjFooter()
    
    /// 加载更多失败,回退页面数
    func loadMoreFailureResetCurrentPage()
}

/// 包含分页的PageVM设置
protocol PageVMSetting: PageVMBaseSetting {
    /// 刷新状态值
    var refreshSubject: PublishSubject<MJRefreshAction> { get }
}
