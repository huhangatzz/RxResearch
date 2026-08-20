//
//  SearchResultViewModel.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx
import Moya

class SearchResultViewModel: BaseTableViewModel, VMInputs, VMOutputs, PageVMSetting {
    
    private let keyword: String
    
    init(keyword: String) {
        self.keyword = keyword
        super.init()
    }
    
    /// outputs
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            refresh()
        case .loadMore:
            loadMore()
        }
    }
}

// MARK: - 网络请求,普通列表数据
private extension SearchResultViewModel {
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }
    
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum, loadMoreFailureResetCurrentPageCallback: loadMoreFailureResetCurrentPage)
    }
    
    func requestData(page: Int, loadMoreFailureResetCurrentPageCallback: (() -> Void)? = nil) {
        homeProvider.rx.request(HomeService.queryKeyword(keyword, page))
            .map(BaseModel<Page<Info>>.self)
            .compactMap { $0.data } //已经去data了
            .asObservable()
            .asSingle()
            .subscribe { event in
                
                //停止刷新
                self.pageNum == 0 ? self.refreshSubject.onNext(.stopRefresh) : self.refreshSubject.onNext(.stopLoadmore)
                
                switch event {
                case .success(let pageModel):
                    if let datas = pageModel.datas {
                        if self.pageNum == 0 {
                            self.dataSource.accept(datas)
                        } else {
                            self.dataSource.accept(self.dataSource.value+datas)
                        }
                    }
                    
                    if pageModel.isNoMoreData {
                        self.refreshSubject.onNext(.showNomoreData)
                    }
                case .failure:
                    loadMoreFailureResetCurrentPageCallback?()
                }
                
                /// 数据源为空才展示错误页面
                if self.dataSource.value.isEmpty {
                    self.processRxMoyaRequestEvent(event: event)
                }
            }
            .disposed(by: disposeBag)
    }
}
