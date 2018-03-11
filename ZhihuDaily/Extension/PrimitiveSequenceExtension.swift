//
//  PrimitiveSequenceExtension.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import HandyJSON
import Moya

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapObject<T: HandyJSON>(_ type: T.Type) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(JSONDeserializer.deserializeFrom(json: try response.mapString()) ?? T())
        }
    }
}
