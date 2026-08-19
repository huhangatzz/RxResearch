//
//  BaseViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/12.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import NSObject_Rx

import Moya
import SnapKit
import RswiftResources
import SVProgressHUD

#if DEBUG
import FunnyButton
import LifetimeTracker
#endif

class BaseViewController: UIViewController {

    /// 全屏网络错误图。首次需要展示时才创建，避免每个页面启动时解码图片。
    private var errorImage: UIImageView?
    
    /*
     错误异常重试
     它表示一个用户事件：用户点击了错误图，请重试。
     Void 表示这个事件只关心“发生了”，不携带具体数据。
     */
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
        
        // 背景颜色
        view.backgroundColor = .clear

        // 设置统一返回按钮的方法,所有的控制器继承该基类即可
        let leftBarButtonItem = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(leftBarButtonItemAction(_:)))
        navigationItem.leftBarButtonItem = (navigationController?.viewControllers.count ?? 0) > 1 ? leftBarButtonItem : nil
        navigationItem.hidesBackButton = true
        
        //导航栏样式
        iOS15NavigationBarClear()
        //abBar 样式
        iOS15TabBarClear()
        
        //只会在深色/浅色模式变化时更新 SVProgressHUD 样式，不会因其他无关 trait 变化重复执行
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (_: BaseViewController, _: UITraitCollection) in
            SVProgressHUD.styleSetting()
        }
        
    }
    
    @objc func leftBarButtonItemAction(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    /// 写在extension分类中的方法不能被重写必须写在class里面
    @discardableResult
    func pushToWebViewController(webLoadInfo: WebLoadInfo, isNeedShowCollection: Bool = true) -> WebViewController {
        let vc = WebViewController(webLoadInfo: webLoadInfo, isNeedShowCollection: isNeedShowCollection)
        navigationController?.pushViewController(vc, animated: true)
        return vc
    }
    
    deinit {
        deinitDDLog()
    }
}

// MARK: - 网络请求错误页面的配置
extension BaseViewController {
    /// 首次展示网络错误时才创建视图、加载图片并绑定重试事件。
    private func setupErrorImageIfNeeded() -> UIImageView {
        if let errorImage {
            return errorImage
        }

        let errorImage = UIImageView(image: R.image.notFound())
        errorImage.contentMode = .scaleAspectFit
        errorImage.isUserInteractionEnabled = true
        errorImage.backgroundColor = .playAndroidBackground

        view.addSubview(errorImage)
        errorImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        //点击错误图重试 RxGesture
        errorImage.rx.tapGesture()//监听图片手势
            .when(.recognized)//只保留识别成功的点击事件
            .map { _ in }//把手势对象事件转成 Void事件
            .bind(to: errorRetry)//把点击事件发送给 errorRetry
            .disposed(by: rx.disposeBag)//控制器销毁时取消监听

        self.errorImage = errorImage
        return errorImage
    }

    func showErrorImage() {
        let errorImage = setupErrorImageIfNeeded()
        errorImage.isHidden = false
        view.bringSubviewToFront(errorImage)
    }

    func hiddenErrorImage() {
        guard let errorImage else { return }
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
/*
 这是 RxCocoa 的 Binder 自定义 UI 绑定属性，专门给你的 BaseViewController 做 Rx 绑定：数据流发送 MoyaError?，自动控制页面错误占位图显示 / 隐藏。
 where Base: BaseViewController 只有 BaseViewController 以及它的子类，才会拥有 .rx.networkError 这个属性
 */
extension Reactive where Base: BaseViewController {//
    /// 显示网络错误
    var networkError: Binder<MoyaError?> {
        /*
         base：就是当前的 BaseViewController 实例，对应 vc。
         回调闭包参数：
         第一个：vc = 当前控制器实例
         第二个：error = 上游 Observable 传过来的值，类型 MoyaError?
         */
        return Binder(base) { vc, error in
            if let _ = error {//收到 MoyaError → 展示错误图
                vc.showErrorImage()
            } else {//收到 nil → 隐藏错误图
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
