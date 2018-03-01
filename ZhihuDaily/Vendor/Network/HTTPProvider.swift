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

    @discardableResult
    func request<T: HandyJSON>(_ target: Target,
                    cache: ((T?) -> Void)? = nil,
                    success: @escaping (T?) -> Void,
                    failure: @escaping (Error?) -> ()) -> Cancellable {
        
        if let cacheData = HTTPCache.cacheData(target) as? Data {
            let json = String(data: cacheData, encoding: .utf8)
            cache.map({
                $0(JSONDeserializer<T>.deserializeFrom(json: json))
            })
        }
        
        debugPrint("-----start request-----")
        debugPrint("baseURL:", target.baseURL)
        switch target.task {
        case .requestParameters(let parameters, _):
            debugPrint("parameters:", parameters)
        default:
            break
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
                debugPrint("-----request success-----")
                do {
                    let json = try response.mapString()
                    success(JSONDeserializer<T>.deserializeFrom(json: json))
                    if let data = json.data(using: .utf8) {
                        HTTPCache.saveDataToDisk(data, target: target)
                    }
                } catch {
                    success(nil)
                }
            case .failure(let error):
                debugPrint("-----request failure-----")
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
