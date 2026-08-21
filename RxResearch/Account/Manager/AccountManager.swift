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
    
    /// 这个是尝试在一个接口调用另一个接口获取的模型
    let myCoinRelay = BehaviorRelay<CoinRank?>(value: nil)
    let myUnreadMessageCountRelay = BehaviorRelay<Int>(value: 0)
    
    /// 悼念模式 (公祭日app全部展示黑白灰色的样式)
    var isGrayModeRelay = BehaviorRelay(value: false)
    
    /// 体系Cell的布局模式
    @CodableUserDefault(key: "kLayoutType", defaultValue: .wrap)
    var layoutType: LayoutType
    
    /// 本地保存用户名
    @UserDefault(key: kUsername, defaultValue: nil)
    var username: String?
    
    /// 本地保存密码
    /// ⚠️ 安全警告：密码以明文形式存储在 UserDefaults 中
    /// TODO: 考虑使用 Keychain 存储敏感信息，或使用 KeychainAccess 等安全库
    @UserDefault(key: kPassword, defaultValue: nil)
    var password: String?
    
    /// 单例
    static let shared = AccountManager()
    
    /// 对外只读用户信息属性
    private(set) var accountInfo: AccountInfo?
    
    /// 私有化初始化方法
    private init() {}
}

extension AccountManager {
    
    /// 登出成功,清理登录信息
    func clearAccountInfo() {
        isLoginRelay.accept(false)
        accountInfo = nil
        myCoinRelay.accept(nil)
        myUnreadMessageCountRelay.accept(0)
        /// 不仅要清除内存,也要清除本地UserDefault保存的数据
        $username.remove()
        $password.remove()
        
    }
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
