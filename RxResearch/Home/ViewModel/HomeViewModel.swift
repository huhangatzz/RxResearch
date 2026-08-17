//
//  HomeViewModel.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/13.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import Moya

class HomeViewModel: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {
    var pageNum: Int
    
    init(pageNum: Int) {
        self.pageNum = pageNum
        super.init()
        mock()
    }
    
    //outputs
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    let banners = BehaviorRelay<[Banner]>(value: [])
    
    /// 首次进入由控制器直接请求，不自动播放下拉刷新动画。
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .stopRefresh)
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            /// 合并请求
            Single.zip(bannerData(), topArticleData(), refresh())
                .subscribe { event in
                    //订阅事件
                    self.refreshSubject.onNext(.stopRefresh)
                    switch event {
                    case .success(let tuple):
                        self.networkError.onNext(nil)
                        let items = tuple.0
                        let topInfos = tuple.1
                        let normalPageModel = tuple.2
                        
                        /// 合并数组并赋值
                        if let normalInfos = normalPageModel.data?.datas {
                            self.dataSource.accept(topInfos + normalInfos)
                        }
                        
                        if let curPage = normalPageModel.data?.curPage,
                           let pageCount = normalPageModel.data?.pageCount {
                            /// 如果发现它们相等,说明是最后一个,改变foot而状态
                            if curPage == pageCount {
                                self.refreshSubject.onNext(.showNomoreData)
                            }
                        }
                        
                        self.banners.accept(items)
                    case .failure(let error):
                        guard let moyaError = error as? MoyaError else { return }
                        if self.dataSource.value.isEmpty {
                            self.networkError.onNext(moyaError)
                        }
                    }
                }
                .disposed(by: disposeBag)
        case .loadMore:
            loadMore()
            /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
                .compactMap { $0.data }
                .asObservable()
                .asSingle()
                .subscribe { event in
                    /// 订阅事件
                    self.refreshSubject.onNext(.stopLoadmore)
                    
                    switch event {
                    case .success(let pageModel):
                        if let datas = pageModel.datas {
                            self.dataSource.accept(self.dataSource.value + datas)
                        }
                        
                        if pageModel.isNoMoreData {
                            self.refreshSubject.onNext(.showNomoreData)
                        }
                    case .failure:
                        self.loadMoreFailureResetCurrentPage()
                    }
                }
                .disposed(by: disposeBag)
        }
    }
}

// MARK: - 网络请求
private extension HomeViewModel {
    /// 下拉刷新操作
    func refresh() -> Single<BaseModel<Page<Info>>> {
        resetCurrentPageAndMjFooter()
        return requestData(page: pageNum)
    }
    
    /// 上拉加载操作
    func loadMore() -> Single<BaseModel<Page<Info>>> {
        pageNum = pageNum + 1
        return requestData(page: pageNum)
    }
    
    /// 普通列表数据
    /// - Parameter page: 页码
    /// - Returns: Single<BaseModel<Page<Info>>>
    func requestData(page: Int) -> Single<BaseModel<Page<Info>>> {
        let result = homeProvider.rx.request(HomeService.normalArticle(page))
            .map(BaseModel<Page<Info>>.self)
            .catchAndReturn(BaseModel<Page<Info>>(data: nil, errorCode: nil, errorMsg: nil))
        return result
    }
    
    /// 置顶文章
    /// - Returns: Single<[Info]>
    func topArticleData() -> Single<[Info]> {
        let result = homeProvider.rx.request(HomeService.topArticle)
            .map(BaseModel<[Info]>.self)
            .compactMap { $0.data }
            .catchAndReturn([])
            .asObservable()
            .asSingle()
        return result
    }
    
    /// 轮播图
    /// - Returns: Single<[Banner]>
    func bannerData() -> Single<[Banner]> {
        let result = homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
            .compactMap { $0.data }
            .catchAndReturn([])
            .asObservable()
            .asSingle()
        return result
    }
}

extension HomeViewModel {
    /// 重置PageNum与上拉组件
    func resetCurrentPageAndMjFooter() {
        pageNum = 0
        refreshSubject.onNext(.resetNomoreData)
    }
    
    /// loadMore失败,回退pageNum
    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}

extension HomeViewModel {
    private func mock() {
        mockProvider.rx.request(.mourn)
            .map(BaseModel<Bool>.self)
            .compactMap { $0.data }
            .asObservable()
            .asSingle()
            .subscribe { event in
                switch event {
                case .success(let value):
                    AccountManager.shared.isGrayModeRelay.accept(false)
                case .failure:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
