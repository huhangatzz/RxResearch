//
//  Provider.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation
import Moya
import RxCocoa
import SVProgressHUD
import MJRefresh

/// 当前可见页面是否正在执行下拉刷新或上拉加载。
/// 刷新控件已经提供了加载反馈，此时不应再叠加全局 HUD。
var isVisibleListRefreshing: Bool {
    let windows = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .filter { !$0.isHidden }

    func containsRefreshingComponent(in view: UIView) -> Bool {
        if let scrollView = view as? UIScrollView,
           scrollView.mj_header?.isRefreshing == true || scrollView.mj_footer?.isRefreshing == true {
            return true
        }
        return view.subviews.contains(where: containsRefreshingComponent)
    }

    return windows.contains { containsRefreshingComponent(in: $0) }
}

/// loading开始与取消插件
let activityPlugin = NetworkActivityPlugin { (state, targetType) in
    
    /// 启动初期的网络状态可能还没有更新；有缓存降级能力时仍继续 HUD 流程。
    if AccountManager.shared.networkIsReachableRelay.value == false,
       !plugins.contains(where: { $0 is ResponseCachePlugin }) {
        SVProgressHUD.showText("似乎已断开与互联网的连接")
        return
    }
    
    if let showLoading = targetType.headers?["showLoading"],
       showLoading == "false" {
        return
    }

    switch state {
    case .began:
        DispatchQueue.main.async {
            guard !isVisibleListRefreshing else { return }
            SVProgressHUD.beginLoading()
        }
    case .ended:
        /// 不论请求开始时是否显示过 HUD，结束时都安全地执行关闭。
        DispatchQueue.main.async {
            SVProgressHUD.stopLoading()
        }
    }
}

/// 响应拦截器插件
let responseInterceptorPlugin = ResponseInterceptorPlugin()

/// 响应缓存插件
let responseCachePlugin = ResponseCachePlugin()

/// 插件集合
let plugins: [PluginType] = [activityPlugin, responseInterceptorPlugin, responseCachePlugin]

/// 首页
let homeProvider = MoyaProvider<HomeService>(plugins: plugins)

/// 我的
let myEndpointClosure = { (target: MyService) -> Endpoint in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: AccountManager.shared.isLoginRelay.value ? ["cookie": AccountManager.shared.cookieHeaderValue] : .empty)
}
let myProvider = MoyaProvider<MyService>(endpointClosure: myEndpointClosure, plugins: plugins)

/// 悼念数据业务
let mockProvider = MoyaProvider(stubClosure: MoyaProvider<MockService>.immediatelyStub)
