//
//  HomeComponent.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import HandyJSON

class HomeComponent: BaseComponent {
    
    func requestLatestNewsList(cache: @escaping (HomeNewsListModel?) -> Void,
                               success: @escaping (HomeNewsListModel?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let request = HTTPRequest(path: ZHRequestType.homeLatestNews.rawValue, needsCache: true)
        startRequest(request: request, cache: { (model) in
            cache(model)
        }, success: { (model) in
            success(model)
        }) { (error) in
            failure(error)
        }
    }
    
    func requestBeforeNewsList(date: String,
                               success: @escaping (HomeNewsListModel?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let path = ZHRequestType.homeBeforeNews.rawValue + date
        let request = HTTPRequest(path: path)
        startRequest(request: request, success: { (model) in
            success(model)
        }) { (error) in
            failure(error)
        }
    }
    
    func requestNewsDetail(newsID: String,
                           success: @escaping (NewsDetailModel?) -> Void,
                           failure: @escaping (Error?) -> Void) {
        let path = ZHRequestType.newsDetail.rawValue + newsID
        let request = HTTPRequest(path: path)
        startRequest(request: request, success: { (model) in
            success(model)
        }) { (error) in
            failure(error)
        }
    }
}
