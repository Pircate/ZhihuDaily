//
//  NetworkConfig.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/2.
//  Copyright © 2018年 adinnet. All rights reserved.
//

public enum NetworkEnvironment {
    case develop
    case product
    
    static let environment: NetworkEnvironment = .develop
    
    var baseURL: String {
        switch self {
        case .develop:
            return "https://news-at.zhihu.com/api"
        case .product:
            return ""
        }
    }
    
    var uploadURL: String {
        switch self {
        case .develop:
            return "http://192.168.20.70/upload/"
        case .product:
            return "http://192.168.20.70/upload/"
        }
    }
    
    var H5BaseURL: String {
        switch self {
        case .develop:
            return "http://192.168.1.135/"
        case .product:
            return ""
        }
    }
}
