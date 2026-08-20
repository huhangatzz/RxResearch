//
//  LayoutType.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/20.
//

import Foundation

enum LayoutType: CaseIterable {
    case wrap
    case list
}

extension LayoutType {
    var title: String {
        switch self {
        case .wrap:
            return "换行布局"
        case .list:
            return "列表布局"
        }
    }
}

extension LayoutType: Codable {}
