//
//  ObserverType+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/12.
//

import RxSwift

extension ObserverType where Element == Void {
    public func onNext() {
        on(.next(()))
    }
}
