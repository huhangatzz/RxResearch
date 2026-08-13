//
//  HomeViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit

import RxSwift
import RxSwiftExt
import RxCocoa
import NSObject_Rx

class HomeViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

}

//app第一次安装时获取网络权限后刷新数据
extension HomeViewController : TabBarVCChildrenRefreshProtocol {
    
}
