//
//  BaseTableViewModel.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx

class BaseTableViewModel: BaseViewModel {
    
    var pageNum: Int
    
    /// 刷新控件命令是一次性事件，不需要向新订阅者重放上一条命令。
    let refreshSubject = PublishSubject<MJRefreshAction>()
    
    init(pageNum: Int = 1) {
        self.pageNum = pageNum
        super.init()
    }
}

extension BaseTableViewModel {
    /// 重置PageNum与上拉组件
    func resetCurrentPageAndMjFooter() {
        pageNum = 0
        refreshSubject.onNext(.resetNomoreData)
    }
    
    /// loadMore失败,回退pageNum
    func loadMoreFailureResetCurrentPage() {
        pageNum = max(0, pageNum - 1)
    }
    
    /// 完成刷新状态
    func finishLoading(_ actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            refreshSubject.onNext(.stopRefresh)
        case .loadMore:
            refreshSubject.onNext(.stopLoadmore)
        }
    }
}
