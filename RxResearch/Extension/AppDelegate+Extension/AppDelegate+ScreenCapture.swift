//
//  AppDelegate+ScreenCapture.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation
import UIKit

extension AppDelegate {
    
    func setupScreenCaptureMonitoring() {
        // 监听截屏
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main) { _ in
                debugLog("屏幕正在被截屏")
            }
        
        // 监听录屏
        NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main) { _ in
                if UIScreen.isCurrentScreenCaptured {
                    debugLog("屏幕正在被捕获，可以在这里做一些隐藏内容的操作")
                } else {
                    debugLog("屏幕没有被捕获，可以移除那个覆盖的视图")
                }
            }
    }
}

extension UIScreen {
    /// 获取当前活跃场景对应的screen，兼容iOS26废弃UIScreen.main
    static func getCurrentScreen() -> UIScreen? {
        // 取激活的窗口场景
        guard let scene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first else {
            return nil
        }
        return scene.screen
    }
    
    /// 判断当前屏幕是否正在被捕获（录屏 / 投屏）
    static var isCurrentScreenCaptured: Bool {
        getCurrentScreen()?.isCaptured ?? false
    }
}
