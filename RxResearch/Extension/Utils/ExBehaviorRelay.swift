//
//  ExBehaviorRelay.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/12.
//

import RxRelay
import RxSwift

/// 对 `BehaviorRelay` 的轻量封装，可按订阅忽略当前值。
///
/// `isIgnoreInitValue` 只影响订阅时是否立即发送当前值，不影响 `value` 的保存和后续 `accept` 事件。
public final class ExBehaviorRelay<Element>: ObservableType {

    /// 每个新订阅是否忽略订阅瞬间的当前值。
    public let isIgnoreInitValue: Bool

    private let relay: BehaviorRelay<Element>

    public func accept(_ event: Element) {
        relay.accept(event)
    }

    public var value: Element {
        relay.value
    }

    public init(value: Element,
                isIgnoreInitValue: Bool = false) {
        self.relay = BehaviorRelay(value: value)
        self.isIgnoreInitValue = isIgnoreInitValue
    }

    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer: ObserverType, Element == Observer.Element {
        observable.subscribe(observer)
    }

    public func asObservable() -> Observable<Element> {
        observable
    }

    private var observable: Observable<Element> {
        let source = relay.asObservable()
        return isIgnoreInitValue ? source.skip(1) : source
    }
}

extension ObservableType {

    public func bind(to relays: ExBehaviorRelay<Element>...) -> Disposable {
        self.bind(to: relays)
    }

    public func bind(to relays: ExBehaviorRelay<Element?>...) -> Disposable {
        self.map { $0 as Element? }.bind(to: relays)
    }

    private func bind(to relays: [ExBehaviorRelay<Element>]) -> Disposable {
        subscribe(onNext: { element in
            relays.forEach {
                $0.accept(element)
            }
        })
    }
}
