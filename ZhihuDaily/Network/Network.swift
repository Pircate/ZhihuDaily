//
//  Network.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/9.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Moya
import HandyJSON

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
    
    public func request<T: HandyJSON>(cache: ((T) -> Void)? = nil,
                                      success: @escaping (T) -> Void,
                                      failure: @escaping (Error) -> ()) {
        MultiProvider.shared.request(.target(self), cache: { (data) in
            cache.map({
                let json = String.init(data: data, encoding: .utf8)
                $0(JSONDeserializer<T>.deserializeFrom(json: json) ?? T())
            })
        }, success: { (response) in
            do {
                let json = try response.filterSuccessfulStatusAndRedirectCodes().mapString()
                success(JSONDeserializer<T>.deserializeFrom(json: json) ?? T())
            } catch {}
        }) { (error) in
            failure(error)
        }
    }
}

fileprivate final class MultiProvider {
    static let shared = HTTPProvider<MultiTarget>()
}
