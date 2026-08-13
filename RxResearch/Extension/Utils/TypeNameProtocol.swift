//
//  TypeNameProtocol.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/13.
//

import Foundation

protocol TypeNameProtocol {
    var className: String { get }
    static var className: String { get }
}

extension TypeNameProtocol {
    var className: String { String(describing: self) }
    static var className: String { String(describing: self) }
    
    /// 用于非继承NSObject的class\enum\struct去掉命名空间的名称打印
    var classNameWithoutNamespace: String {
        if self is NSObject {
            return self.className
        } else {
            return className.replacingOccurrences(of: "\(nameSpace ?? "").", with: "")
        }
    }
    
    static var classNameWithoutNamespace: String {
        if self is NSObject.Type {
            return className
        } else {
            return className.replacingOccurrences(of: "\(nameSpace ?? "").", with: "")
        }
    }
    
}

//让NSObject默认继承此协议
extension NSObject: TypeNameProtocol {}
