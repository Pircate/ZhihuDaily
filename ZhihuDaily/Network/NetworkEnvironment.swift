//
//  NetworkConfig.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/2.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import Moya
import RxSwiftX

extension Network {
    
    enum Environment {
        case develop
        case product
        
        var baseURL: URL {
            switch self {
            case .develop:
                return URL(string: "https://news-at.zhihu.com/api")!
            case .product:
                return URL(string: "https://news-at.zhihu.com/api")!
            }
        }
    }
    
    static var environment: Environment = .develop
}

extension TargetType {
    var baseURL: URL {
        return Network.environment.baseURL
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var headers: [String: String]? {
        return nil
    }
}
