//
//  HTTPProvider.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/1.
//  Copyright © 2018年 adinnet. All rights reserved.
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
        MultiProvider.shared.request(.target(self), cache: cache, success: success, failure: failure)
    }
}

fileprivate final class MultiProvider {
    static let shared = HTTPProvider<MultiTarget>()
    private init() {}
}

extension NetworkActivityPlugin {
    static var numberOfRequests: Int = 0 {
        didSet {
            if numberOfRequests > 1 { return }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = self.numberOfRequests > 0
            }
        }
    }
}

open class HTTPProvider<Target: TargetType>: MoyaProvider<Target> {
    
    init() {
        let networkActivityPlugin = NetworkActivityPlugin { (changeType, target) in
            switch changeType {
            case .began:
                NetworkActivityPlugin.numberOfRequests += 1
            case .ended:
                NetworkActivityPlugin.numberOfRequests -= 1
            }
        }
        super.init(plugins: [HTTPLoggerPlugin(), networkActivityPlugin])
    }
    
    @discardableResult
    open func request<T: HandyJSON>(_ target: Target,
                                    cache: ((T) -> Void)? = nil,
                                    success: @escaping (T) -> Void,
                                    failure: @escaping (Error) -> ()) -> Cancellable {
        
        if let cache = cache {
            do {
                if let data = target.method == .get
                    ? URLCache.shared.cachedResponse(for: try endpoint(target).urlRequest())?.data
                    : HTTPCache.shared.cachedData(for: target) {
                    let json = String(data: data, encoding: .utf8)
                    cache(JSONDeserializer<T>.deserializeFrom(json: json) ?? T())
                }
            } catch {}
        }
        
        return request(target, completion: { (result) in
            switch result {
            case .success(let response):
                do {
                    let json = try response.filterSuccessfulStatusAndRedirectCodes().mapString()
                    success(JSONDeserializer<T>.deserializeFrom(json: json) ?? T())
                    
                    guard cache != nil else { return }
                    guard target.method != .get else { return }
                    HTTPCache.shared.storeCachedData(response.data, for: target)
                } catch {}
            case .failure(let error):
                failure(error)
            }
        })
    }
}
