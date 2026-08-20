//
//  TreeCell.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/20.
//

import UIKit
import RxRelay
import RxCocoa

import FlexLayout

class TreeCell: BaseDisposeBagCell {

    let buttonTap = PublishRelay<TabModel>()

    private var _model: TabModel!
    
    var model: TabModel {
        set {
            wrapLayout(model: newValue)
        }
        get {
            return _model
        }
    }
    
    
}

extension TreeCell {
    private func setupUI() {}
    
    fileprivate func wrapLayout(model: TabModel) {
        
    }
    
}
