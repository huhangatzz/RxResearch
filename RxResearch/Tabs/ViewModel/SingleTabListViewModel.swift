//
//  SingleTabListViewModel.swift
//  RxResearch
//
//  Created by Codex on 2026/8/20.
//

import Foundation
import Moya
import NSObject_Rx
import RxCocoa
import RxSwift

final class SingleTabListViewModel: BaseTableViewModel, VMInputs, VMOutputs, PageVMSetting {
    
    private let type: TagType
    private let tabID: Int
    
    let dataSource = BehaviorRelay<[Info]>(value: [])

    init(type: TagType, tabID: Int) {
        self.type = type
        self.tabID = tabID
        super.init(pageNum: type.pageNum)
    }

    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            pageNum = type.pageNum
            refreshSubject.onNext(.resetNomoreData)
        case .loadMore:
            pageNum += 1
        }
        requestData(page: pageNum, actionType: actionType)
    }
}

private extension SingleTabListViewModel {
    func requestData(page: Int, actionType: ScrollViewActionType) {
        tabsProvider.rx.request(.articles(type: type, tabID: tabID, page: page))
            .map(BaseModel<Page<Info>>.self)
            .subscribe { [weak self] event in
                guard let self else { return }
                
                finishLoading(actionType)

                switch event {
                case .success(let response):
                    let pageModel = response.data
                    let items = pageModel?.datas ?? []
                    
                    if actionType == .refresh {
                        dataSource.accept(items)
                    } else {
                        dataSource.accept(dataSource.value + items)
                    }
                    networkError.onNext(nil)

                    if pageModel?.isNoMoreData == true, !dataSource.value.isEmpty {
                        refreshSubject.onNext(.showNomoreData)
                    }
                case .failure(let error):
                    if actionType == .loadMore {
                        pageNum = max(type.pageNum, page - 1)
                    }
                    if dataSource.value.isEmpty, let moyaError = error as? MoyaError {
                        networkError.onNext(moyaError)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
