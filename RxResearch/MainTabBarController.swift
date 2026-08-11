//
//  MainTabBarController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx

class MainTabBarController: UITabBarController {

    private let titles = TabType.allCases.map { $0.title }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = titles.first
        view.backgroundColor = .playAndroidBackground
        
        addChildControllers()
        networkListening()
        
        //悼念灰色模式 使用在国家公祭日、全国哀悼日等纪念活动
        bindGrayMode()
    }
    
    // MARK: - 添加所有子控制器
    private func addChildControllers() {
        TabType.allCases.forEach { type in
            addSubviewController(type: type)
        }
    }
    
    // MARK: - 添加子控制器
    private func addSubviewController(type: TabType) {
        let subVC = type.viewController
        subVC.tabBarItem.title = type.title
        subVC.tabBarItem.image = UIImage(named: type.imageName)
        subVC.tabBarItem.selectedImage = UIImage(named: type.selectImageName)
        subVC.title = type.title
        addChild(subVC)
    }
}

extension MainTabBarController {
    private func networkListening() {

        //用来解决首次安装获取网络权限问题
        let isFirst = UserDefaults.standard.value(forKey: kIsFirst)
        guard isFirst == nil else { return }
        
        NetworkMonitor.shared.isConnectedObservable
            .filter { $0 }
            .take(1)
            .subscribe { [weak self] _ in //进入闭包,必有网
                guard let self else { return }
                
                self.refreshChildren()
                UserDefaults.standard.setValue(false, forKey: kIsFirst)
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func refreshChildren() {
        guard let currentVC = selectedViewController as? TabBarVCChildrenRefreshProtocol else { return }
        
        currentVC.dataRefresh()
    }
    
}
