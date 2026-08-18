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

/// 屏宽
let kScreenWidth = UIScreen.main.bounds.width

/// 屏宽的9/16
let kScreenWidth_9_16 = UIScreen.main.bounds.width / 16.0 * 9

/// 屏高
let kScreenHeight = UIScreen.main.bounds.height

/// 整体顶部间距(竖屏限定)
let kTopMargin = kStatusBarHeight + kNavigationBarHeight

/// tabbar的高度 从图层看是48
let kTabbarHeight: CGFloat = 49

/// 整体底部间距 从图层看是83 但是图层的tabbar的高度是48, 底部安全区间距是34 48 + 34 = 82
let kBottomMargin = kSafeBottomMargin + kTabbarHeight

/// 是否是第一次进入App
let kIsFirst = "IsFirst"
