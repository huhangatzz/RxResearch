//
//  Provider.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation
import Moya
import RxCocoa

//活动指示器插件
let activityPlugin = activityHUDPlugin

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
