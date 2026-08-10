//
//  UITraitCollection+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import UIKit

//处理暗黑模式
extension UITraitCollection {
    static var isDark: Bool { UITraitCollection.current.isDark }
    static var isLight: Bool { UITraitCollection.current.isLight }
    static var isUnspecified: Bool { UITraitCollection.current.isUnspecified }
    
    var isDark: Bool { userInterfaceStyle == .dark }
    var isLight: Bool { userInterfaceStyle == .light }
    //跟随系统设置
    var isUnspecified: Bool { userInterfaceStyle == .unspecified }
    
}
