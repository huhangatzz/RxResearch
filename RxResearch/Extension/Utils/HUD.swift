//
//  HUD.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation

protocol HUD {
    static func beginLoading()
    static func stopLoading()
    static func showText(_ text: String)
}
