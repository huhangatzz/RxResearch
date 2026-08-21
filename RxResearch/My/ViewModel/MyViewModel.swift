//
//  MyViewModel.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/21.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx
import Moya

class MyViewModel: BaseTableViewModel {

    let currentDataSource = BehaviorRelay<[My]>(value: [])
    
    init() {
        super.init()
        
        /// 单例的isLogin通过map后,与VM的currentDataSource进行绑定
        AccountManager.shared.isLoginRelay
            .map { isLogin in
                isLogin ? My.loginDataSource : My.logoutDataSource
            }
            .bind(to: currentDataSource)
            .disposed(by: disposeBag)
    }

    func loadData() {
        Single.zip(getMyCoin(), getMyUnreadMessageCount())
            .subscribe { event in
                self.refreshSubject.onNext(.stopRefresh)
                
                switch event {
                case .success((let myCoin, let count)):
                    AccountManager.shared.myCoinRelay.accept(myCoin)
                    AccountManager.shared.myUnreadMessageCountRelay.accept(count)
                case .failure:
                    AccountManager.shared.myCoinRelay.accept(nil)
                    AccountManager.shared.myUnreadMessageCountRelay.accept(0)
                }
            }
            .disposed(by: disposeBag)
    }
    
}

extension MyViewModel {
    private func getMyCoin() -> Single<CoinRank> {
        myProvider.rx.request(MyService.userCoinInfo)
            .map(BaseModel<CoinRank>.self)
            .map { $0.data }
            .compactMap { $0 }
            .catchAndReturn(CoinRank())
            .asObservable()
            .asSingle()
    }
    
    private func getMyUnreadMessageCount() -> Single<Int> {
        myProvider.rx.request(MyService.unreadCount)
            .map(BaseModel<Int>.self)
            .map { $0.data }
            .compactMap { $0 }
            .catchAndReturn(0)
            .asObservable()
            .asSingle()
    }
    
    func logout() -> Single<BaseModel<String>> {
        accountProvider.rx.request(AccountService.logout)
            .map(BaseModel<String>.self)
    }
}
