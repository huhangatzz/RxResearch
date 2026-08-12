//
//  HomeViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

}

//app第一次安装时获取网络权限后刷新数据
extension HomeViewController : TabBarVCChildrenRefreshProtocol {
    
}
