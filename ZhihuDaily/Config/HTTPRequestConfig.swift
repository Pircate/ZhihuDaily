//
//  HTTPRequestConfig.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation

enum ZHRequestType: String, HTTPRequestType {
    var value: String {
        return rawValue
    }
    
    case none = ""
    case homeBanner = "news/hot"
    case homeLatestNews = "news/latest"
    case homeBeforeNews = "news/before"
}
