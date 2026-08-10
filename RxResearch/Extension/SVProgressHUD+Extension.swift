//
//  SVProgressHUD+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import SVProgressHUD

//展示活动提示器
extension SVProgressHUD {
    static func setting() {
        SVProgressHUD.setImageViewSize(.zero)
        styleSetting()
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
    }
    
    static func styleSetting() {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.traitCollection.isDark == true ? SVProgressHUD.setDefaultStyle(.light) : SVProgressHUD.setDefaultStyle(.dark)
    }
}
