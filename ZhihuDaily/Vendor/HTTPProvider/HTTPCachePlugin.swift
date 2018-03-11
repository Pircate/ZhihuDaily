//
//  HTTPProvider+Rx.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Moya
import Result

struct HTTPCachePlugin: PluginType {
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            HTTPCache.shared.storeCachedData(response.data, for: target)
        case .failure:
            break
        }
    }
}
