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
    
    /// 首次进入由控制器直接请求，不自动播放下拉刷新动画。
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .stopRefresh)
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            /*
             Single.zip合并请求,规则如下:
             三个都成功：整体成功。
             任意一个失败：整体失败。
             成功结果按顺序组成元组。
             */
            Single.zip(bannerData(), topArticleData(), refresh())
                .subscribe { event in
                    
                    //无论成功失败，当前代码都会先停止下拉刷新
                    self.refreshSubject.onNext(.stopRefresh)
                    
                    switch event {
                    case .success(let tuple):
                        
                        //刷新成功,隐藏错误视图
                        self.networkError.onNext(nil)
                        
                        //拆开三个结果
                        let items = tuple.0
                        let topInfos = tuple.1
                        let normalPageModel = tuple.2
                        
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
                        
                        //获取轮播图数据
                        self.banners.accept(items)
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
            /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
            /// 在 Single 上使用 compactMap 后，如果结果是 nil，可能形成“没有元素”的序列，所以代码才又做了：.asObservable()和.asSingle()
                .compactMap { $0.data }//过滤掉nil数据
                .asObservable()
                .asSingle()
                .subscribe { event in
                    
                    /// 结束刷新
                    self.refreshSubject.onNext(.stopLoadmore)
                    
                    switch event {
                    case .success(let pageModel):
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
                    AccountManager.shared.isGrayModeRelay.accept(value)
                case .failure:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
