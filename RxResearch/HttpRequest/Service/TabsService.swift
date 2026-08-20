//
//  TabsService.swift
//  RxResearch
//
//  Created by Codex on 2026/8/20.
//

import Foundation
import Alamofire
import Moya

/// 统一管理分段页面的标签和文章列表接口。
enum TabsService {
    case tags(TagType)
    case articles(type: TagType, tabID: Int, page: Int)
}

extension TabsService: TargetType {
    var baseURL: URL {
        switch self {
        case .articles(type: .course, tabID: _, page: _):
            return URL(string: Api.newBaseUrl)!
        default:
            return URL(string: Api.baseUrl)!
        }
    }

    var path: String {
        switch self {
        case .tags(let type):
            switch type {
            case .project: return Api.Project.tags
            case .publicNumber: return Api.PublicNumber.tags
            case .tree: return Api.Tree.tags
            case .course: return Api.Course.tags
            }
        case .articles(let type, let tabID, let page):
            switch type {
            case .project: return Api.Project.tagList + page.toString + "/json"
            case .publicNumber: return Api.PublicNumber.tagList + tabID.toString + "/" + page.toString + "/json"
            case .tree: return Api.Tree.tagList + page.toString + "/json"
            case .course: return Api.Course.tagList + page.toString + "/json"
            }
        }
    }

    var method: Moya.Method { .get }

    var sampleData: Data { Data() }

    var task: Task {
        switch self {
        case .tags, .articles(type: .publicNumber, tabID: _, page: _):
            return .requestPlain
        case .articles(let type, let tabID, _):
            var parameters: [String: Any] = ["cid": tabID]
            if type == .course {
                parameters["order_type"] = 1
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? { nil }
}
