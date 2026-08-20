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
    
    /// 关键字
    private let keyword: String
    
    /// outputs
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    init(keyword: String) {
        self.keyword = keyword
        super.init()
    }
    
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
    private func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum, actionType: .refresh)
    }
    
    private func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum, actionType: .loadMore)
    }

    //请求数据
    private func requestData(page: Int, actionType: ScrollViewActionType) {
        homeProvider.rx.request(HomeService.queryKeyword(keyword, page))
            .map(BaseModel<Page<Info>>.self)
            .subscribe { [weak self] event in
                guard let self else { return }

                finishLoading(actionType)

                switch event {
                case .success(let response):
                    let pageModel = response.data
                    let newItems = pageModel?.datas ?? []

                    switch actionType {
                    case .refresh:
                        dataSource.accept(newItems)
                    case .loadMore:
                        dataSource.accept(dataSource.value + newItems)
                    }

                    // 请求成功后清除可能存在的全屏网络错误状态。
                    networkError.onNext(nil)

                    // 空列表由 EmptyDataSet 表达，不重复展示“已经全部加载完毕”。
                    if pageModel?.isNoMoreData == true, !dataSource.value.isEmpty {
                        refreshSubject.onNext(.showNomoreData)
                    }
                case .failure(let error):
                    if case .loadMore = actionType {
                        // 按本次失败的页码回退，避免并发状态下对当前页重复减一。
                        loadMoreFailureResetCurrentPage()
                    }

                    // 有旧数据时保留列表；没有内容时才展示全屏网络错误。
                    if dataSource.value.isEmpty,
                       let moyaError = error as? MoyaError {
                        networkError.onNext(moyaError)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
