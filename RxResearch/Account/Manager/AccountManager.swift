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
    
    /// 是否登录的BehaviorRelay属性
    let isLoginRelay = BehaviorRelay(value: false)
    
    /// 悼念模式 (公祭日app全部展示黑白灰色的样式)
    var isGrayModeRelay = BehaviorRelay(value: false)
    
    /// 单例
    static let shared = AccountManager()
    
    /// 对外只读用户信息属性
    private(set) var accountInfo: AccountInfo?
    
    /// 私有化初始化方法
    private init() {}
}

extension AccountManager {
    /// 更新收藏夹
    func updateCollectIds(_ collectIds: [Int]) {
        AccountManager.shared.accountInfo?.collectIds = collectIds
    }
}

extension AccountManager {
    /// 已登录请求头处理
    var cookieHeaderValue: String {
        if let username = accountInfo?.username,
           let password = accountInfo?.password {
          return "loginUserName=\(username);loginUserPassword=\(password)"
        } else {
          return ""
        }
    }
}
