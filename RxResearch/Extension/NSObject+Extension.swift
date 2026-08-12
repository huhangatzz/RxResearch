//
//  NSObject+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/12.
//

import Foundation
import CocoaLumberjack

extension NSObject {
    
    /// 对象获取类的字符串名称
    public var className: String { runtimeType.className }
    
    /// 类获取类的字符串名称
    public static var className: String { String(describing: self) }
    
    /// NSObject对象获取类型
    public var runtimeType: NSObject.Type { type(of: self) }
    
}

protocol DeinitPrintable {
    func deinitPrint()
    
    func deinitDDLog()
}

extension DeinitPrintable where Self: NSObject {
    func deinitPrint() {
        #if DEBUG
        print("\(className)被销毁了")
        #endif
    }
    
    func deinitDDLog() {
        DDLogDebug("\(className)被销毁了")
    }
}

extension NSObject: DeinitPrintable {}
