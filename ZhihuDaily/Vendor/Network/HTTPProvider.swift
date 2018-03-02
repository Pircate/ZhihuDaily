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
        return URL(string: NetworkEnvironment.develop.baseUrl)!
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

open class HTTPProvider<Target: TargetType>: MoyaProvider<Target> {
    
    var numberOfRequests = 0
    
    init() {
        super.init(plugins: [HTTPLoggerPlugin()])
    }

    @discardableResult
    func request<T: HandyJSON>(_ target: Target,
                               cache: ((T) -> Void)? = nil,
                               success: @escaping (T) -> Void,
                               failure: @escaping (Error?) -> ()) -> Cancellable {
        
        if let cache = cache {
            if let cacheData = HTTPCache.cacheData(target) as? Data {
                let json = String(data: cacheData, encoding: .utf8)
                cache(JSONDeserializer<T>.deserializeFrom(json: json) ?? T())
            }
        }
        
        numberOfRequests += 1
        setNetworkActivityIndicatorVisible(true)
        return request(target, completion: { (result) in
            self.numberOfRequests -= 1
            if self.numberOfRequests == 0 {
                self.setNetworkActivityIndicatorVisible(false)
            }
            switch result {
            case .success(let response):
                do {
                    let json = try response.filterSuccessfulStatusCodes().mapString()
                    success(JSONDeserializer<T>.deserializeFrom(json: json) ?? T())
                    
                    guard cache != nil else { return }
                    HTTPCache.saveDataToDisk(response.data, target: target)
                } catch {}
            case .failure(let error):
                failure(error)
            }
        })
    }
    
    private func setNetworkActivityIndicatorVisible(_ isVisible: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
        }
    }
}
