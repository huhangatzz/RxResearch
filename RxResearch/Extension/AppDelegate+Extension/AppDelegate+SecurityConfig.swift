//
//  AppDelegate+SecurityConfig.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation

extension AppDelegate {

    /// 设置安全配置（API密钥管理）
    func setupSecurityConfiguration() {
        loadObfuscatedKeys()
    }

    // MARK: - 方案五：混淆技术
    private func loadObfuscatedKeys() {
        print("aliapyKey:\(aliapyKey) wechatKey:\(wechatKey) geTuiKey:\(geTuiKey) gaodeKey: \(gaodeKey)")
    }
}
