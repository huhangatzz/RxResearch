//
//  UIColor+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit

extension UIColor {
    public convenience init(lightThemeColor: UIColor, darkThemeColor: UIColor? = nil) {
        //因为是逃逸闭包并有返回值,所以需要traitCollection -> UIColo这样写
        //只要系统样式有变化,就会执行闭包
        self.init { traitCollection -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightThemeColor
            case .unspecified:
                return lightThemeColor
            case .dark:
                return darkThemeColor ?? lightThemeColor
            @unknown default://安全兜底，避免版本更新 App 崩溃
                fatalError()
            }
        }
    }
}

extension UIColor {
    // 随机颜色
    static var random: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIColor {
    
    // 文字颜色 light为黑 dark为白
    static let playAndroidTitle = UIColor(lightThemeColor: .black, darkThemeColor: .white)
    
    // 背景颜色 light为白 dark为黑
    static let playAndroidBackground = UIColor(lightThemeColor: .white, darkThemeColor: .black)

}
