//
//  HotKeyFlexBoxViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import UIKit
import RxSwift
import RxSwiftExt
import RxCocoa
import TheRouter

class HotKeyFlexBoxViewController: BaseViewController {

    /// TheRouter 会通过 Objective-C KVC 将 userInfo 中的同名字段注入进来。
    @objc dynamic var upTestContext: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        debugLog("HotKeyFlexBoxViewController 路由参数 upTestContext：\(upTestContext)")
    }

}

//这个页面使用路由跳转
/// 为了保证运行时可以便利到TheRouterable协议,需要Xcode16需要Build Settings -> Build Options -> Enable Debug Dylib Support -> NO
extension HotKeyFlexBoxViewController: TheRouterable {
    static var patternString: [String] = [hotKeyFlexBox]
}

public class TheRouterApi: NSObject, CustomRouterInfo {
    public static var patternString: String = hotKeyFlexBox
    public static var routerClass = "RxResearch.HotKeyFlexBoxViewController"
    public var params: [String : Any] { return [:] }
    public var jumpType: LAJumpType = .push
}
