//
//  AppDelegate+NetworkConfig.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import NSObject_Rx

extension AppDelegate {
    
    // 监听网络状态
    func setupNetworkMonitoring() {
        // 使用原生 NWPathMonitor 进行监听 (iOS 13+)
        setupNativeNetworkMonitor()
    }
    
    // MARK: - 使用原生 NWPathMonitor
    private func setupNativeNetworkMonitor() {
        //多余代码,使用Rx监听即可
//        NetworkMonitor.shared.addListener { status in
//            print("isConnected=\(status.isConnected), interface=\(status.interface)")
//            let value = status.isConnected
//            AccountManager.shared.networkIsReachableRelay.accept(value)
//        }
        
        NetworkMonitor.shared.start()
        
        NetworkMonitor.shared.statusObservable
            .distinctUntilChanged()
            .subscribe { status in
                debugLog("Rx网络监听: isConnected=\(status.isConnected), interface=\(status.interface)")
                let value = status.isConnected
                AccountManager.shared.networkIsReachableRelay.accept(value)
            }
            .disposed(by: rx.disposeBag)
        
    }
    
}
