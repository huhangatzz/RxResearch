//
//  TabModel.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/20.
//

import Foundation

protocol TabAble {
    associatedtype T: TabAble & Codable
    
    var children: [T]? { get }
    var courseId: Int? { get }
    var id: Int? { get }
    var name: String? { get }
    var order: Int? { get }
    var parentChapterId: Int? { get }
    var userControlSetTop: Bool? { get }
    var visible: Int? { get }
}

struct TabModel: Codable {

    let children: [TabModel]?
    let courseId: Int?
    let id: Int?
    let name: String?
    let order: Int?
    let parentChapterId: Int?
    let userControlSetTop: Bool?
    let visible: Int?

}

extension TabModel: TabAble {}
