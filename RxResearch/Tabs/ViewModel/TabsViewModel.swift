//
//  TabsViewModel.swift
//  RxResearch
//
//  Created by Codex on 2026/8/20.
//

import Foundation
import Moya
import NSObject_Rx
import RxCocoa
import RxSwift

typealias TreeViewModel = TabsViewModel

final class TabsViewModel: BaseTableViewModel {
    
    private let type: TagType
    
    let dataSource = BehaviorRelay<[TabModel]>(value: [])

    init(type: TagType) {
        self.type = type
        super.init()
    }

    func loadData() {
        tabsProvider.rx.request(.tags(type))
            .map(BaseModel<[TabModel]>.self)
            .subscribe { [weak self] event in
                guard let self else { return }
                refreshSubject.onNext(.stopRefresh)

                switch event {
                case .success(let response):
                    dataSource.accept(response.data ?? [])
                    networkError.onNext(nil)
                case .failure(let error):
                    if dataSource.value.isEmpty, let moyaError = error as? MoyaError {
                        networkError.onNext(moyaError)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
