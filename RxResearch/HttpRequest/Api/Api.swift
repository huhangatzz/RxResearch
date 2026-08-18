//
//  Api.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation

enum Api {
    
    #if DEBUG // 测试环境

    nonisolated static let baseUrl = "https://www.wanandroid.com/"
    static let newBaseUrl = "https://wanandroid.com/"
    
    #else// 正式环境
    
    nonisolated static let baseUrl = "https://www.wanandroid.com/"
    static let newBaseUrl = "https://wanandroid.com/"
    
    #endif
}

/// 首页
extension Api {
    enum Home {
        static let banner = "banner/json"

        static let topArticle = "article/top/json"

        static let normalArticle = "article/list/"

        static let hotKey = "hotkey/json"

        static let queryKeyword = "article/query/"
    }
}


extension Api {
    /// 我的 取消收藏和点击收藏操作为post,其他为get
    enum My {
        
        static let collectArticle = "lg/collect/"

        static let unCollectArticle = "lg/uncollect_originId/"
 
    }
}


//悼念接口
extension Api {
    enum Mock {
        nonisolated static let mourn = "mourn/json"
    }
}
