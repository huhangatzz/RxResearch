//
//  SVProgressHUD+Extension.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import SVProgressHUD

extension SVProgressHUD: HUD {
    
    static func beginLoading() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
    }
    
    static func stopLoading() {
        SVProgressHUD.dismiss()
    }
    
    static func showText(_ text: String) {
        SVProgressHUD.show(UIImage(), status: text)
    }
}

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
