//
//  BaseViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/12.
//

import UIKit
import RswiftResources

import RxSwift
import RxCocoa
import RxGesture
import Moya

import SnapKit
import NSObject_Rx
import SVProgressHUD

#if DEBUG
import FunnyButton
import LifetimeTracker
#endif

class BaseViewController: UIViewController {

    private lazy var errorImage: UIImageView = {
        let imageView = UIImageView(image: R.image.notFound())
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .playAndroidBackground
        return imageView
    }()
    
    /// 错误异常重试
    let errorRetry = PublishSubject<Void>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        #if DEBUG
            trackLifetime()
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// 最简单的设置统一返回按钮的方法,所有的控制器继承该基类即可
        let leftBarButtonItem = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(leftBarButtonItemAction(_:)))
        navigationItem.leftBarButtonItem = (navigationController?.viewControllers.count ?? 0) > 1 ? leftBarButtonItem : nil
        navigationItem.hidesBackButton = true
        
        view.backgroundColor = .clear
        
        iOS15NavigationBarClear()
        iOS15TabBarClear()
        
        //只会在深色/浅色模式变化时更新 SVProgressHUD 样式，不会因其他无关 trait 变化重复执行
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (_: BaseViewController, _: UITraitCollection) in
            SVProgressHUD.styleSetting()
        }
        
        setupErrorImage()
    }
    
    @objc func leftBarButtonItemAction(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        deinitDDLog()
    }
}

// MARK: - 网络请求错误页面的配置
extension BaseViewController {
    
    private func setupErrorImage() {
        view.addSubview(errorImage)
        errorImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        errorImage.isHidden = true
        
        errorImage.rx.tapGesture()
            .when(.recognized)
            .map { _ in }
            .bind(to: errorRetry)
            .disposed(by: rx.disposeBag)
    }
    
    func showErrorImage() {
        errorImage.isHidden = false
        view.bringSubviewToFront(errorImage)
    }
    
    func hiddenErrorImage() {
        errorImage.isHidden = true
        view.sendSubviewToBack(errorImage)
    }
}

extension BaseViewController {
    private func iOS15NavigationBarClear() {
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    private func iOS15TabBarClear() {
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
}

extension BaseViewController {
    /// push到目标控制器,并通过类名进行定向移除导航控制器中的栈内控制器
    /// - Parameters:
    ///   - viewController: 目标控制器
    ///   - animated: 是否有动画效果
    ///   - removeViewControllerClassNameList: 需要移除控制器名称的数组
    ///   - isRemoveSelf: 是否移除触发push方法的当前控制器
    func pushViewController(_ viewController: UIViewController, animated: Bool, removeViewControllerClassNameList: [String] = [], isRemoveSelf: Bool = true) {
        
        navigationController?.pushViewController(viewController, animated: animated)
        var removeList = removeViewControllerClassNameList
        if isRemoveSelf {
            removeList.append(self.className)
        }
        navigationController?.removeViewControllerByClassNames(removeList, animated: false)
    }
    
    /// 用于通过类名进行定向pop
    /// - Parameters:
    ///   - className: pop回退到的控制器名称
    ///   - animated: 是否有动画效果
    ///   - completion: pop完成后的回调
    func popToViewController(className: String, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        
        var isPoped = false
        
        for vc in self.navigationController?.viewControllers ?? [] where vc.className == className {
            navigationController?.popToViewController(vc, animated: animated)
            isPoped = true
            break
        }
        
        if !isPoped {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - 绑定
extension Reactive where Base: BaseViewController {
    /// 显示网络错误
    var networkError: Binder<MoyaError?> {
        return Binder(base) { vc, error in
            if let _ = error {
                vc.showErrorImage()
            } else {
                vc.hiddenErrorImage()
            }
        }
    }
}

// MARK: - FunnyButton的使用
 extension BaseViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    #if DEBUG
        replaceFunnyAction {
            print("点我干森莫")
        }
    #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    #if DEBUG
        removeFunnyActions()
    #endif
        
    }
 }

// MARK: - LifetimeTracker的使用
#if DEBUG
extension BaseViewController: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "VC")
    }
}
#endif
