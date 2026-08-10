//
//  Collection+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation

//Collection 协议：数组Array、Set、Dictionary、String、Slice 只要遵守 Collection 全部自动获得这个计算属性
extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}
