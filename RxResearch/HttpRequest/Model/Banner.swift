//
//  Banner.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation

struct Banner: Codable {
    var id: Int?
    
    var title: String?
    
    var originId: Int?
    
    var link: String? { url }
        
    let desc: String?
    
    let imagePath: String?
    let isVisible: Int?
    let order: Int?
    
    let type: Int?
    let url: String?
}

extension Banner: WebLoadInfo {}
