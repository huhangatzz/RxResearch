//
//  HomeService.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/17.
//

import Foundation
import Moya
import Alamofire

enum HomeService {
    case banner
    case topArticle
    case normalArticle(_ page: Int)
    case hotKey
    case queryKeyword(_ keyword: String, _ page: Int)
}

extension HomeService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .banner:
            return Api.Home.banner
        case .topArticle:
            return Api.Home.topArticle
        case .normalArticle(let page):
            return Api.Home.normalArticle + page.toString + "/json"
        case .hotKey:
            return Api.Home.hotKey
        case .queryKeyword(_, let page):
            return Api.Home.queryKeyword + page.toString + "/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .queryKeyword:
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .hotKey:
            return try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "HotKey", ofType: "json")!))
        default:
            return Data()
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .queryKeyword(let keyword, _):
            return .requestParameters(parameters: ["k": keyword], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .banner, .topArticle:
            // 非关键请求不单独控制全局 HUD，避免多个并发请求互相干扰加载状态。
            return ["showLoading": "false"]
        default:
            return nil
        }
    }
}
