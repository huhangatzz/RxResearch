//
//  Api.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation

enum Api {
    nonisolated static let baseUrl = "https://www.wanandroid.com/"
    static let newBaseUrl = "https://wanandroid.com/"
}

/// 首页
extension Api {
    //queryKeyword是post请求 其他的是get请求
    enum Home {
        static let banner = "banner/json"

        static let topArticle = "article/top/json"

        static let normalArticle = "article/list/"

        static let hotKey = "hotkey/json"

        static let queryKeyword = "article/query/"
    }
}





extension Api {
    enum Mock {
        nonisolated static let mourn = "mourn/json"
    }
}
