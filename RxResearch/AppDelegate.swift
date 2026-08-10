//
//  AppDelegate.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    /// 服务路由
    let serivceHost = "scheme://services?"

    /// web跳转路由
    let webRouterUrl = "scheme://webview/home"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        //基础设置
        setupAppConfiguration()
        //监听崩溃
        setupCrashHandler()
        //日志
        setupLogConfiguration()
        //监听路由
        setupRouterConfigurtaion()
        //监听网络状态
        setupNetworkMonitoring()
        //监听屏幕截屏和录屏
        setupScreenCaptureMonitoring()
        //秘钥处理
        setupSecurityConfiguration()
        
        // MARK: - 调试工具配置(页面上的悬浮按钮)
        setupDebugTools()
        
        
        // MARK: - 调试日志
        logPrintDebug()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

}

