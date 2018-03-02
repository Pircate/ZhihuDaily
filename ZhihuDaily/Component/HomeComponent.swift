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
                               cache: ((T) -> Void)? = nil,
                               success: @escaping (T) -> Void,
                               failure: @escaping (Error?) -> Void) {
        provider.request(target, cache: cache, success: success, failure: failure)
    }
}

extension HomeComponent: Factorable {
    var needsUnload: Bool {
        return provider.numberOfRequests == 0
    }
}
