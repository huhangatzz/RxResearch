//
//  Page.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation

struct Page<Content: Codable>: Codable {
    let curPage: Int?
    let datas: [Content]? //是数组类型的泛型
    let offset: Int?
    let over: Bool?
    let pageCount: Int?
    let size: Int?
    let total: Int?
}

extension Page {
    /// 自定义属性来判断是否到底了
    var isNoMoreData: Bool {
        if let curPage = self.curPage, let pageCount = self.pageCount {
            if curPage == pageCount {
                return true
            } else {
                return false
            }
        }
        return false
    }
}
