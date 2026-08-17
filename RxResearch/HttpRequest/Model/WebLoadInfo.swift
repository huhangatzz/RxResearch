//
//  WebLoadInfo.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation

protocol WebLoadInfo {
    var id: Int? { get set }
    var originId: Int? { get set }
    var title: String? { get set }
    var link: String? { get }
}
