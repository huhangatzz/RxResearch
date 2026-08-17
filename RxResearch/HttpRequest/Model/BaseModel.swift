//
//  BaseModel.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation

struct BaseModel<T: Codable>: Codable {
    let data: T?
    let errorCode: Int?
    let errorMsg: String?
}

extension BaseModel {
    /// 请求是否成功
    var isSuccess: Bool { errorCode == 0 }
}
