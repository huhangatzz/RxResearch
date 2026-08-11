//
//  TabType.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import Foundation
import UIKit
import RswiftResources

enum TabType: CaseIterable {
    case home
    case project
    case publicNumber
    case tree
    case my
}

extension TabType {
    var viewController: UIViewController {
        switch self {
        case .home:
            return HomeViewController()
        case .project:
            return TabsViewController()
        case .publicNumber:
            return TabsViewController()
        case .tree:
            return TreeViewController()
        case .my:
            return MyViewController()
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "首页"
        case .project:
            return "项目"
        case .publicNumber:
            return "公众号"
        case .tree:
            return "体系"
        case .my:
            return "我的"
        }
    }
    
    var imageName: String {
        switch self {
        case .home:
            return R.image.home.name
        case .project:
            return R.image.project.name
        case .publicNumber:
            return R.image.publicNumber.name
        case .tree:
            return R.image.tree.name
        case .my:
            return R.image.my.name
        }
    }
    
    var selectImageName: String {
        switch self {
        case .home:
            return R.image.home_selected.name
        case .project:
            return R.image.project_selected.name
        case .publicNumber:
            return R.image.publicNumber_selected.name
        case .tree:
            return R.image.tree_selected.name
        case .my:
            return R.image.my_selected.name
        }
    }
}
