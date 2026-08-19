//
//  BaseRequestable.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import Foundation

import RxSwift
import Moya

/*
 复用重复的接口 使用协议间接实现多继承
 */

//第一种方式
protocol BaseRequestable {}

protocol HotKeyRequest: BaseRequestable {
    func requestHotKey() -> Single<Moya.Response>
}

extension HotKeyRequest {
    func requestHotKey() -> Single<Moya.Response> {
        homeProvider.rx.request(HomeService.hotKey)
    }
}

//第二种方式(我觉得第一种方式要简洁些,不用些什么继承了,直接使用Repository调用即可)
protocol RepositoryProtocol {
    static func requestHotKey() -> Single<Moya.Response>
}

extension RepositoryProtocol {
    static func requestHotKey() -> Single<Moya.Response> {
        homeProvider.rx.request(HomeService.hotKey)
    }
}

enum Repository: RepositoryProtocol {}
