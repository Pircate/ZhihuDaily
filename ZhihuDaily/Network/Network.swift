//
//  Network.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/9.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Moya

extension TargetType {
    var baseURL: URL {
        return URL(string: NetworkEnvironment.environment.baseURL)!
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
