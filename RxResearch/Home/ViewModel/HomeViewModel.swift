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
    
    init(pageNum: Int = 1) {
        self.pageNum = pageNum
        super.init()
        mock()
    }
    
    //outputs
    
    /*
     它是首页文章数据的“当前状态”
     为什么用 BehaviorRelay？因为它：
     永远保存最新值
     新订阅者会立即收到当前值
     不会发出 .error
     不会发出 .completed
     通过 accept() 更新
     */
    let dataSource = BehaviorRelay<[Info]>(value: [])
    //轮播图数据
    let banners = BehaviorRelay<[Banner]>(value: [])
    
    /// 刷新控件命令是一次性事件，不需要向新订阅者重放上一条命令。
    let refreshSubject = PublishSubject<MJRefreshAction>()
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            // 首次进入先展示有效缓存；下拉刷新时保留当前数据，不用旧缓存覆盖。
            loadCachedHomeDataIfNeeded()
            // 轮播图目前不参与首屏列表展示，独立请求，避免阻塞文章数据。
            refreshBannerData()
            /*
             Single.zip合并请求,规则如下:
             两个都成功：整体成功。
             任意一个失败：整体失败。
             成功结果按顺序组成元组。
             */
            Single.zip(topArticleData(), refresh())
                .subscribe { event in
                    
                    //无论成功失败，当前代码都会先停止下拉刷新
                    self.refreshSubject.onNext(.stopRefresh)
                    
                    switch event {
                    case .success(let tuple):

                        //刷新成功,隐藏错误视图
                        self.networkError.onNext(nil)

                        //拆开置顶文章和普通文章结果
                        let topInfos = tuple.0
                        let normalPageModel = tuple.1
                        
                        /// 合并置顶文章和普通文章
                        if let normalInfos = normalPageModel.data?.datas {
                            //使用accept进行更新,重新装载数据
                            //刷新：用新数据替换旧数据
                            self.dataSource.accept(topInfos + normalInfos)
                        }
                        
                        if let curPage = normalPageModel.data?.curPage,
                           let pageCount = normalPageModel.data?.pageCount {
                            /// 如果发现它们相等,说明是最后一个,改变footer的状态
                            if curPage == pageCount {
                                //显示无更多数据
                                self.refreshSubject.onNext(.showNomoreData)
                            }
                        }
                        
                    case .failure(let error):
                        //判断错误是否是MoyaError
                        guard let moyaError = error as? MoyaError else { return }
                        
                        /*
                         这里有一个重要规则：
                         请求失败 + 当前没有任何旧数据 → 展示全屏错误图
                         请求失败 + 当前还有旧数据     → 保留旧列表，不覆盖页面
                         */
                        if self.dataSource.value.isEmpty {
                            self.networkError.onNext(moyaError)
                        }
                    }
                }
                .disposed(by: disposeBag)
        case .loadMore:
            loadMore()
                .subscribe { event in
                    
                    /// 结束刷新
                    self.refreshSubject.onNext(.stopLoadmore)
                    
                    switch event {
                    case .success(let response):
                        guard let pageModel = response.data else {
                            // 接口成功返回但分页数据为空时，同样回退预增的页码。
                            self.loadMoreFailureResetCurrentPage()
                            return
                        }
                        
                        //加载更多：旧数据 + 下一页数据
                        if let datas = pageModel.datas {
                            self.dataSource.accept(self.dataSource.value + datas)
                        }
                        
                        //判断是否没有更多数据
                        if pageModel.isNoMoreData {
                            self.refreshSubject.onNext(.showNomoreData)
                        }
                    case .failure:
                        //失败后需要回退,否则下次加载会跳过失败的那一页
                        self.loadMoreFailureResetCurrentPage()
                    }
                }
                .disposed(by: disposeBag)
        }
    }
}

// MARK: - 网络请求
private extension HomeViewModel {
    /// 首屏采用 stale-while-revalidate：立即展示缓存，后续网络结果再覆盖它。
    func loadCachedHomeDataIfNeeded() {
        guard dataSource.value.isEmpty else { return }

        let normalTarget = HomeService.normalArticle(0)
        guard let normalResponse = responseCachePlugin.cachedResponse(for: normalTarget),
              let normalModel = try? normalResponse.map(BaseModel<Page<Info>>.self),
              let normalInfos = normalModel.data?.datas else {
            return
        }

        var topInfos: [Info] = []
        if let topResponse = responseCachePlugin.cachedResponse(for: HomeService.topArticle),
           let topModel = try? topResponse.map(BaseModel<[Info]>.self) {
            topInfos = topModel.data ?? []
        }

        dataSource.accept(topInfos + normalInfos)

        if let bannerResponse = responseCachePlugin.cachedResponse(for: HomeService.banner),
           let bannerModel = try? bannerResponse.map(BaseModel<[Banner]>.self) {
            banners.accept(bannerModel.data ?? [])
        }
    }

    /// 轮播图是非关键模块，它的耗时或失败不应阻塞首屏文章。
    func refreshBannerData() {
        bannerData()
            .subscribe(onSuccess: { [weak self] items in
                self?.banners.accept(items)
            })
            .disposed(by: disposeBag)
    }

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
    
    /// 普通文章
    /// - Parameter page: 页码
    /// - Returns: Single<BaseModel<Page<Info>>>
    func requestData(page: Int) -> Single<BaseModel<Page<Info>>> {
        homeProvider.rx.request(HomeService.normalArticle(page))
            .map(BaseModel<Page<Info>>.self)
    }
    
    /// 置顶文章
    /// - Returns: Single<[Info]>
    func topArticleData() -> Single<[Info]> {
        homeProvider.rx.request(HomeService.topArticle)
            .map(BaseModel<[Info]>.self)
            .map { $0.data ?? [] }
            .catchAndReturn([])
    }
    
    /// 轮播图
    /// - Returns: Single<[Banner]>
    func bannerData() -> Single<[Banner]> {
        homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
            .map { $0.data ?? [] }
            .catchAndReturn([])
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
                    AccountManager.shared.isGrayModeRelay.accept(value)
                case .failure:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
