//
//  HTTPProvider.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/1.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import Moya
import Result

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
    
    public typealias TargetTaskClosure = (Target) -> Task
    
    open let taskClosure: TargetTaskClosure
    
    init(taskClosure: @escaping TargetTaskClosure = { $0.task }) {
        let networkActivityPlugin = NetworkActivityPlugin { (changeType, target) in
            switch changeType {
            case .began:
                NetworkActivityPlugin.numberOfRequests += 1
            case .ended:
                NetworkActivityPlugin.numberOfRequests -= 1
            }
        }
        self.taskClosure = taskClosure
        super.init(plugins: [HTTPLoggerPlugin(), networkActivityPlugin])
    }
    
    open override func endpoint(_ token: Target) -> Endpoint {
        return super.endpoint(token).replacing(task: taskClosure(token))
    }
    
    @discardableResult
    open func request(_ target: Target,
                      cache: ((Data) -> Void)? = nil,
                      success: @escaping (Moya.Response) -> Void,
                      failure: @escaping (Error) -> ()) -> Cancellable {
        
        if let cache = cache {
            do {
                if let data = target.method == .get
                    ? URLCache.shared.cachedResponse(for: try endpoint(target).urlRequest())?.data
                    : HTTPCache.shared.cachedData(for: target) {
                    cache(data)
                }
            } catch {}
        }
        
        return request(target) { (result) in
            switch result {
            case .success(let response):
                success(response)
                guard cache != nil else { return }
                guard target.method != .get else { return }
                HTTPCache.shared.storeCachedData(response.data, for: target)
            case .failure(let error):
                failure(error)
            }
        }
    }
}
