//
//  Constant.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import UIKit

/// 状态栏的高度(竖屏限定)
let kStatusBarHeight: CGFloat = 47
/// 导航栏的高度(竖屏限定)
let kNavigationBarHeight: CGFloat = 44.0

/// 底部安全区间距(竖屏限定) 34
let kSafeBottomMargin: CGFloat = UIApplication.shared.mainWindow?.safeAreaInsets.bottom ?? 0

/// 必须这么显式的编写,才能表示其意义
let void: Void = ()

/// 命名空间
let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
//可以使用 Bundle.main.executableName,后续测试看是否一致

/// 当前活跃窗口的宽度。使用计算属性，避免在 App 启动时过早固化尺寸。
var kScreenWidth: CGFloat {
    UIApplication.shared.mainWindow?.bounds.width ?? 0
}

/// 当前活跃窗口宽度对应的 9:16 高度。
var kScreenWidth_9_16: CGFloat {
    kScreenWidth / 16 * 9
}

/// 当前活跃窗口的高度。
var kScreenHeight: CGFloat {
    UIApplication.shared.mainWindow?.bounds.height ?? 0
}

/// 整体顶部间距(竖屏限定)
let kTopMargin = kStatusBarHeight + kNavigationBarHeight

/// tabbar的高度 从图层看是48
let kTabbarHeight: CGFloat = 49

/// 整体底部间距 从图层看是83 但是图层的tabbar的高度是48, 底部安全区间距是34 48 + 34 = 82
let kBottomMargin = kSafeBottomMargin + kTabbarHeight

/// 是否是第一次进入App
let kIsFirst = "IsFirst"

/// 保存用户名的key
let kUsername = "kUsername"

/// 保存密码的key
let kPassword = "kPassword"
