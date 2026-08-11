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

/// 是否是第一次进入App
let kIsFirst = "IsFirst"
