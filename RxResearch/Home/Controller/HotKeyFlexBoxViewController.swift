//
//  HotKeyFlexBoxViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import UIKit

import RxSwift
import RxSwiftExt
import RxCocoa
import NSObject_Rx

import TheRouter
import Moya

class HotKeyFlexBoxViewController: BaseViewController {

    /// TheRouter 会通过 Objective-C KVC 将 userInfo 中的同名字段注入进来。
    @objc dynamic var upTestContext: String = ""
    
    private lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 34))
        textField.textColor = .black
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 17
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.returnKeyType = .search
        textField.font = UIFont.systemFont(ofSize: 15)
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var rootFlexContainer = UIView()
    
    //初始化轮询接口
    let requester = PollingNetworkRequester(
        interval: .seconds(1),
        maxPollingTime: .seconds(20)) {
        return Repository.requestHotKey()
    }
    
    //模型
    let viewModel = HotKeyViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        polling()
    }
    
    private func setupUI() {
        view.backgroundColor = .playAndroidBackground
        view.addSubview(rootFlexContainer)
        navigationItem.titleView = textField
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        debugLog("HotKeyFlexBoxViewController 路由参数 upTestContext：\(upTestContext)")
    }
    
    private func binding() {
        //点击键盘return
        textField.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe { [weak self] _ in
                guard let self, let keyword = self.textField.text, keyword.isNotEmpty else { return }
                self.pushToSearchResultController(keyword: keyword)
            }
            .disposed(by: rx.disposeBag)
        
        //点击导航栏右按钮
        navigationItem.rightBarButtonItem?.rx.tap
            .map { [weak self] in self?.textField.text }
            .compactMap { $0 }
            .subscribe { [weak self] in
                debugLog("onNext eventt: \($0)")
                self?.pushToSearchResultController(keyword: $0)
            }
            .disposed(by: rx.disposeBag)
        
        //导航栏右按钮是否能点击
        textField.rx.text.orEmpty
            .map { $0.isNotEmpty }
            .bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
    }
    
    private func polling() {
        requester.startListening()
        requester.onPollingEnd = {reason in
            switch reason {
            case .success:
                print("网络请求成功，轮询结束")
            case .failure(let error):
                print("网络请求失败，轮询结束，错误：\(error)")
            case .timeout:
                print("轮询超时结束")
            }
        }
        requester.action()
    }
    
    private func pushToSearchResultController(keyword: String) {
        let vc = SearchResultController(keyword: keyword)
        navigationController?.pushViewController(vc, animated: true)
    }

}

//这个页面使用路由跳转
/// 为了保证运行时可以便利到TheRouterable协议,需要Xcode16需要Build Settings -> Build Options -> Enable Debug Dylib Support -> NO
extension HotKeyFlexBoxViewController: TheRouterable {
    static var patternString: [String] = [hotKeyFlexBox]
}

public class TheRouterApi: NSObject, CustomRouterInfo {
    public static var patternString: String = hotKeyFlexBox
    public static var routerClass = "RxResearch.HotKeyFlexBoxViewController"
    public var params: [String : Any] { return [:] }
    public var jumpType: LAJumpType = .push
}
