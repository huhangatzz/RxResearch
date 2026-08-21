//
//  AccountService.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/21.
//

import Foundation
import Moya
import Alamofire

enum AccountService {
    case login(_ username: String, _ password: String, _ showLoading: Bool)
    case register(_ username: String, _ password: String, _ repassword: String)
    case logout
}

extension AccountService: TargetType {
    
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .login:
            return Api.Account.login
        case .register:
            return Api.Account.register
        case .logout:
            return Api.Account.logout
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .logout:
            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login(let username, let password, _):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: URLEncoding.default)
        case .register(let username, let password, let repassword):
            return .requestParameters(parameters: ["username": username, "password": password, "repassword": repassword], encoding: URLEncoding.default)
        case .logout:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .login(_, _, let showLoading):
            return ["showLoading": "\(showLoading)"]
        default:
            return nil
        }
    }
}
