//
//  AppDelegate+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

extension AppDelegate {
    
    func setupAppConfiguration() {
        setupSVProgressHUD()
        setupKeyboardManager()
        setupNetworkActivityLogger()
    }
    
    private func setupSVProgressHUD() {
        SVProgressHUD.setting()
    }
    
    private func setupKeyboardManager() {
        //开启 IQKeyboardManager 核心能力：自动上移视图，防止键盘遮挡输入框
        IQKeyboardManager.shared.isEnabled = true
        //开启输入框上方的键盘辅助工具栏（带上一条 / 下一条、Done 完成按钮）。
        IQKeyboardToolbarManager.shared.isEnabled = true
        //点击输入框外部空白处不会自动收起键盘
        IQKeyboardManager.shared.resignOnTouchOutside = false
        //不强制接管键盘外观
        IQKeyboardManager.shared.keyboardConfiguration.overrideAppearance = false
        //仅当 overrideAppearance = true 的时候这个配置才生效
        IQKeyboardManager.shared.keyboardConfiguration.appearance = .default
    }
    
    private func setupNetworkActivityLogger() {
        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        #endif
    }
}
