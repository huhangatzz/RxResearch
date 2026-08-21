//
//  MyViewController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/11.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import SafariServices

import SVProgressHUD
import MJRefresh

class MyViewController: BaseTableViewController {

    private let viewModel = MyViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension MyViewController {
    private func setupUI() {
        tableView.mj_footer = nil
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        tableView.rowHeight = 44
        
        let myView = MyView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth_9_16))
        tableView.tableHeaderView = myView
    }
    
    private func binding() {
        tableView.mj_header?.rx.refresh
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
        
        //监听登录
        AccountManager.shared.isLoginRelay
            .subscribe { [weak self] event in
                switch event {
                case .next(let value):
                    if value {
                        self?.tableView.mj_header = MJRefreshNormalHeader()
                    } else {
                        self?.tableView.mj_header = nil
                    }
                default: break
                }
            }
            .disposed(by: rx.disposeBag)
        
        if let myView = tableView.tableHeaderView as? MyView {
            AccountManager.shared.myCoinRelay
                .bind(to: myView.rx.myInfo)
                .disposed(by: rx.disposeBag)
        }
        
        viewModel.outputs.currentDataSource
            .asDriver()
            .drive(tableView.rx.items) { [weak self] (tableView, _, my) in
                if my == .logout {
                    let cell = tableView.dequeueReusableCell(withIdentifier: LogoutCell.className) as! LogoutCell
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    return cell
                } else if my == .myMessage {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.className) as! MessageCell
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    
                    if let self {
                        AccountManager.shared.myUnreadMessageCountRelay
                            .bind(to: cell.rx.count)
                            .disposed(by: self.rx.disposeBag)
                    }
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let self else { return }
                
                self.tableView.deselectRow(at: indexPath, animated: false)
                let my = self.viewModel.outputs.currentDataSource.value[indexPath.row]
                switch my {
                case .logout:
                    self.logoutAction(viewModel: self.viewModel)
                case .myMessage:
                    self.toMyMessageController()
                case .myGitHub:
                    let vc = SFSafariViewController(url: URL(string: "https://github.com/huhangatzz")!)
                    vc.dismissButtonStyle = .close
                    self.present(vc, animated: true)
                default:
                    guard let vc = creatInstance(className: my.path) as? UIViewController else { return }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension MyViewController {
    private func logoutAction(viewModel: MyViewModel) {
        let alertController = UIAlertController(title: "提示", message: "是否确定退出登录?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "取消", style: .destructive) { (_) in }
        let actionOK = UIAlertAction(title: "确定", style: .default) { (_) in
            Haptics.success.feedback()
            viewModel.inputs.logout()
                .asDriver(onErrorJustReturn: BaseModel(data: nil, errorCode: nil, errorMsg: nil))
                .drive { baseModel in
                    if baseModel.isSuccess {
                        AccountManager.shared.clearAccountInfo()
                        DispatchQueue.main.async {
                            SVProgressHUD.showText("退出登录成功")
                        }
                    }
                }
                .disposed(by: self.rx.disposeBag)
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionOK)
        present(alertController, animated: true, completion: nil)
    }
    
    private func toMyMessageController() {
        let status = AccountManager.shared.myUnreadMessageCountRelay.value.greaterThanZero ? MessageReadyStatus.unread : MessageReadyStatus.read
    }
}

//测试工具 用来做啥的
extension MyViewController: InnerEventResponsible {
    func innerEventHandle(event: any InnerEventConvertible) {
        guard let type = event as? InnerViewEvent else { return }
        switch type {
        case .custom(let dictionary):
            print(dictionary)
        }
    }
}

extension MyViewController: TabBarVCChildrenRefreshProtocol {
    func dataRefresh() {
        debugLog("\(className) dataRefresh")
        viewModel.inputs.loadData()
    }
}
