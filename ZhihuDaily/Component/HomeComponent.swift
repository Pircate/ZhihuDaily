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
    func requestBannerList(cache: @escaping (HomeBannerListModel?) -> Void,
                           success: @escaping (HomeBannerListModel?) -> Void,
                           failure: @escaping (Error?) -> Void) {
        let request = HTTPRequest(requestName: "3", requestType: ZHRequestType.homeBanner, parameters: nil, needsCache: true)
        startRequest(request: request, cache: { (json) in
            let model = JSONDeserializer<HomeBannerListModel>.deserializeFrom(json: json)
            cache(model)
        }, success: { (json) in
            let model = JSONDeserializer<HomeBannerListModel>.deserializeFrom(json: json)
            success(model)
        }) { (error) in
            failure(error)
        }
    }
    
    func requestLatestNewsList(cache: @escaping (HomeNewsListModel?) -> Void,
                               success: @escaping (HomeNewsListModel?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let request = HTTPRequest(requestName: "4", requestType: ZHRequestType.homeLatestNews, parameters: nil, needsCache: true)
        startRequest(request: request, cache: { (json) in
            let model = JSONDeserializer<HomeNewsListModel>.deserializeFrom(json: json)
            cache(model)
        }, success: { (json) in
            let model = JSONDeserializer<HomeNewsListModel>.deserializeFrom(json: json)
            success(model)
        }) { (error) in
            failure(error)
        }
    }
    
    func requestBeforeNewsList(date: String,
                               success: @escaping (HomeNewsListModel?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let requestName = "4/news/before/\(date)"
        let request = HTTPRequest(requestName: requestName, requestType: ZHRequestType.none, parameters: nil)
        startRequest(request: request, success: { (json) in
            let model = JSONDeserializer<HomeNewsListModel>.deserializeFrom(json: json)
            success(model)
        }) { (error) in
            failure(error)
        }
    }
    
    func requestNewsDetail(newsID: String,
                           success: @escaping (NewsDetailModel?) -> Void,
                           failure: @escaping (Error?) -> Void) {
        let requestName = "4/news/\(newsID)"
        let request = HTTPRequest(requestName: requestName, requestType: ZHRequestType.none, parameters: nil)
        startRequest(request: request, success: { (json) in
            let model = JSONDeserializer<NewsDetailModel>.deserializeFrom(json: json)
            success(model)
        }) { (error) in
            failure(error)
        }
    }
}
