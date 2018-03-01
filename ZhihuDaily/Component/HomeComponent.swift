//
//  HomeComponent.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import HandyJSON
import Moya

enum HomeTarget: TargetType {
    case latestNews
    case beforeNews(date: String)
    case newsDetail(newsID: String)
    
    var path: String {
        switch self {
        case .latestNews:
            return "4/news/latest"
        case .beforeNews(let date):
            return "4/news/before/\(date)"
        case .newsDetail(let newsID):
            return "4/news/\(newsID)"
        }
    }
    
    var task: Task {
        return .requestPlain
    }
}

final class HomeComponent {
    
    private let provider = HTTPProvider<HomeTarget>()
    
    func request<T: HandyJSON>(_ target: HomeTarget,
                               cache: ((T?) -> Void)? = nil,
                               success: @escaping (T?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        provider.request(target, cache: cache, success: success, failure: failure)
    }
    
//    func requestLatestNewsList(cache: @escaping (HomeNewsListModel?) -> Void,
//                               success: @escaping (HomeNewsListModel?) -> Void,
//                               failure: @escaping (Error?) -> Void) {
//
//        let request = HTTPRequest(path: ZHRequestType.homeLatestNews.rawValue, needsCache: true)
//        startRequest(request: request, cache: { (model) in
//            cache(model)
//        }, success: { (model) in
//            success(model)
//        }) { (error) in
//            failure(error)
//        }
//    }
//
//    func requestBeforeNewsList(date: String,
//                               success: @escaping (HomeNewsListModel?) -> Void,
//                               failure: @escaping (Error?) -> Void) {
//        let path = ZHRequestType.homeBeforeNews.rawValue + date
//        let request = HTTPRequest(path: path)
//        startRequest(request: request, success: { (model) in
//            success(model)
//        }) { (error) in
//            failure(error)
//        }
//    }
//
//    func requestNewsDetail(newsID: String,
//                           success: @escaping (NewsDetailModel?) -> Void,
//                           failure: @escaping (Error?) -> Void) {
//        let path = ZHRequestType.newsDetail.rawValue + newsID
//        let request = HTTPRequest(path: path)
//        startRequest(request: request, success: { (model) in
//            success(model)
//        }) { (error) in
//            failure(error)
//        }
//    }
}

extension HomeComponent: Factorable {
    var needsUnload: Bool {
        return provider.numberOfRequests == 0
    }
    
    
}
