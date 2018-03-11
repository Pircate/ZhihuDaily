//
//  HTTPProvider+Rx.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Moya
import RxSwift
import HandyJSON

extension HTTPProvider {
    func cachedObject<T: HandyJSON>(_ target: Target) -> T {
        guard let data = cachedData(target) else { return T() }
        let json = String(data: data, encoding: .utf8)
        return JSONDeserializer<T>.deserializeFrom(json: json) ?? T()
    }
    
    func request<T: HandyJSON>(_ target: Target, cache: ((T) -> Void)? = nil) -> Single<T> {
        if let cache = cache {
            cache(cachedObject(target))
        }
        return rx.request(target).mapObject(T.self)
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapObject<T: HandyJSON>(_ type: T.Type) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(JSONDeserializer.deserializeFrom(json: try response.mapString()) ?? T())
        }
    }
}
