//
//  AccountManager.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

/// 账户管理器（遵循 AccountManageable 协议，支持依赖注入）
final class AccountManager: AccountManageable {
    
    /// 默认是有联网的
    let networkIsReachableRelay = BehaviorRelay(value: true)
    
    /// 悼念模式
    var isGrayModeRelay = BehaviorRelay(value: false)
    
    
    /// 单例
    static let shared = AccountManager()
    
    /// 私有化初始化方法
    private init() {}
}
