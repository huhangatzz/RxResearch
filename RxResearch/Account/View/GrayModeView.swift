//
//  GrayModeView.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

//实现首页或所以页面内容会呈现黑白效果
/*
 实现原理:
 原理不是逐张修改图片，而是在整个页面上方覆盖一层 GrayView，然后利用 Core Animation 的混合滤镜统一降低下面内容的饱和度：
 backgroundColor = .gray
 layer.compositingFilter = "saturationBlendMode"
 
 saturationBlendMode 会将覆盖层的饱和度与下方已经渲染好的画面进行混合。因为灰色本身的饱和度为 0，最终下方内容会呈现黑白效果。
 */
class GrayModeView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .gray
        layer.compositingFilter = "saturationBlendMode"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    /// 首页变灰的方案
    func grayMode(isGrayMode: Bool) {
        if isGrayMode {
            let overlay = GrayModeView(frame: view.bounds)
            view.addSubview(overlay)
            view.bringSubviewToFront(overlay)
        } else {
            let some = view.subviews.first { view in
                if view is GrayModeView {
                    return true
                } else {
                    return false
                }
            }
            
            if let some {
                some.removeFromSuperview()
            }
        }
    }
    
    /// 一刀切所有页面变灰的方案
    func windowGrayMode(isGrayMode: Bool) {
        if let keyWindow = UIApplication.shared.mainWindow {
            if isGrayMode {
                let overlay = GrayModeView(frame: keyWindow.bounds)
                keyWindow.addSubview(overlay)
                keyWindow.bringSubviewToFront(overlay)
            } else {
                let some = keyWindow.subviews.first { view in
                    if view is GrayModeView {
                        return true
                    } else {
                        return false
                    }
                }
                
                if let some {
                    some.removeFromSuperview()
                }
            }
        }
    }
}

extension Reactive where Base: UIViewController {
    var isGrayMode: Binder<Bool> {
        Binder(base) { base, isGrayMode in
            base.grayMode(isGrayMode: isGrayMode)
        }
    }
    
    var windowGrayMode: Binder<Bool> {
        Binder(base) { base, isGrayMode in
            base.windowGrayMode(isGrayMode: isGrayMode)
        }
    }
}

extension UIViewController {
    func bindGrayMode() {
        AccountManager.shared.isGrayModeRelay
            .bind(to: rx.isGrayMode)
            .disposed(by: rx.disposeBag)
    }
    
    func bindWindowGrayMode() {
        AccountManager.shared.isGrayModeRelay
            .bind(to: rx.windowGrayMode)
            .disposed(by: rx.disposeBag)
    }
}
