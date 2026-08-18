//
//  MyService.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/18.
//

import Foundation
import Moya
import Alamofire

enum MyService {
    case collectArticle(_ collectId: Int)
    case unCollectArticle(_ collectId: Int)
}

extension MyService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .collectArticle(let collectId):
            return Api.My.collectArticle + collectId.toString + "/json"
        case .unCollectArticle(let collectId):
            return Api.My.unCollectArticle + collectId.toString + "/json"
  
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .collectArticle, .unCollectArticle:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        switch self {
        case
             .collectArticle,
             .unCollectArticle:
            return nil
        }
    }
}
