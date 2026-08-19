//
//  Theme.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import UIKit

/// 触觉反馈类型
///
/// 使用 `UINotificationFeedbackGenerator` 提供用户反馈
enum Haptics {
    /// 成功反馈
    case success
    
    /// 警告反馈
    case warning
    
    /// 错误反馈
    case error
}

extension Haptics {
    /// 执行触觉反馈
    /// 根据当前枚举值触发相应的系统触觉反馈
    func feedback() {
        let generator = UINotificationFeedbackGenerator()
        switch self {
        case .success:
            generator.notificationOccurred(.success)
        case .warning:
            generator.notificationOccurred(.warning)
        case .error:
            generator.notificationOccurred(.error)
        }
    }
}
