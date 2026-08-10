//
//  AppDelegate+CrashConfig.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation
import KSCrash

extension AppDelegate {
    func setupCrashHandler() {
        let installation = makeEmailInstallation()
        let config = KSCrashConfiguration()
        try? installation.install(with: config)
        
        installation.sendAllReports { array, error in
            if array?.isNotEmpty == true {
                print("发送 \(array?.count ?? 0) reports")
            } else {
                let score = try? CrashReportStore.init(configuration: CrashReportStoreConfiguration())
                score?.deleteAllReports()
                print("发送报告失败: \(error.debugDescription)")
            }
        }
    }
    
    private func makeEmailInstallation() -> CrashInstallation {
        let emailAddress = "huhangatzz@163.com"
        let email = CrashInstallationEmail.shared
        email.recipients = [emailAddress]
        email.subject = "崩溃报告"
        email.message = "这个是一个崩溃报告"
        email.filenameFmt = "crash-report-%d.txt.gz"
        
        email.addConditionalAlert(withTitle: "检测到崩溃", message: "上次启动应用时崩溃了。要发送崩溃报告吗？", yesAnswer: "确定!", noAnswer: "不用谢谢")
        
        email.setReportStyle(.JSON, useDefaultFilenameFormat: true)
        return email
    }
}
