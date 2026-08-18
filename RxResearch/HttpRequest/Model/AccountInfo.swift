//
//  AccountInfo.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/18.
//

import Foundation

struct AccountInfo: Codable {

    let admin: Bool?
    let chapterTops: [Int]?
    var collectIds: [Int]?
    let email: String?
    let icon: String?
    let id: Int?
    let nickname: String?
    var password: String?
    let publicName: String?
    let token: String?
    let type: Int?
    var username: String?
}
