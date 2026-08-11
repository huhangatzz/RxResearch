//
//  BaseNavigationController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit

class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
    }
}

//实现协议都写在扩展中
extension BaseNavigationController: UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
        /// 解决某些情况下push时的假死bug，防止把根控制器pop掉
        if navigationController.viewControllers.count == 1 {
            interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
