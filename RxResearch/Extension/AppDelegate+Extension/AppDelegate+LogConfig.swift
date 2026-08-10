//
//  AppDelegate+LogConfig.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation
import CocoaLumberjack
import SSZipArchive

extension AppDelegate {
    //日志配置
    func setupLogConfiguration() {
        #if DEBUG
        dynamicLogLevel = .verbose
        #else
        dynamicLogLevel = .warning
        #endif
        
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger = DDFileLogger(logFileManager: CustomLogFileManager())
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        fileLogger.logFormatter = CustomLogFormatter()
        
        DDLog.add(fileLogger)
        
        print("logsDirectory: \(fileLogger.logFileManager.logsDirectory)")
        print("sortedLogFilePaths: \(fileLogger.logFileManager.sortedLogFilePaths)")
    }
    
    //上传日志
    func uploadLogs() {
        let fileLogger = DDFileLogger()
        let filePaths = fileLogger.logFileManager.sortedLogFilePaths
        
        guard filePaths.isNotEmpty else { return }
        
        let zipName = "Logs\(Date().timeIntervalSince1970)"
        //let zipPath = fileLogger.logFileManager.logsDirectory.replacingOccurrences(of: "Logs", with: "\(zipName).zip")
        let logsDirURL = URL(fileURLWithPath: fileLogger.logFileManager.logsDirectory)
        let zipFileURL = logsDirURL.deletingLastPathComponent()
            .appendingPathComponent("\(zipName).zip")
        let zipPath = zipFileURL.path

        let result = SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: filePaths)

        if result {
            let zipURL = URL(fileURLWithPath: zipPath)
            print("上传日志: \(zipURL)")
            // TODO: 实现上传逻辑
            //try? FileManager.default.removeItem(atPath: zipPath)
        }
    }
}
