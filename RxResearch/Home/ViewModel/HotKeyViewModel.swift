//
//  HotKeyViewModel.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import Moya

class HotKeyViewModel: BaseViewModel {
    
    /// outputs
    let dataSource = BehaviorRelay<[HotKey]>(value: [])
    
    /// inputs
    func loadData() {
        requestData()
    }
}

// MARK: - 网络请求

private extension HotKeyViewModel {
    func requestData() {
        // 尝试使用重复接口方式 (多个地方使用的接口可以使用这样的方式)
        Repository.requestHotKey()
            .map(BaseModel<[HotKey]>.self) //把 Moya Response JSON 映射成 BaseModel<[HotKey]>
            .map { $0.data ?? [] } //获取BaseModel模型中的data -> 得到[HotKey]数组 (data为nil给空数组，不再抛错)
            .subscribe { [weak self] event in
                guard let self else { return } //使用这样的方法去掉.compactMap { $0 }.asObservable().asSingle()

                switch event {
                case .success(let items):
                    self.dataSource.accept(items)
                case .failure:
                    break
                }
                self.processRxMoyaRequestEvent(event: event)
            }
            .disposed(by: disposeBag)
    }
}
