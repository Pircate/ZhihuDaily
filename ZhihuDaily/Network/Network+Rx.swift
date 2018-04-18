//
//  Network+Rx.swift
//  SwiftNetwork
//
//  Created by GorXion on 2018/4/17.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import Moya
import enum Result.Result
import Cache

extension TargetType {
    
    public var cachedKey: String {
        func parameter(task: Task) -> String {
            switch task {
            case .requestParameters(let parameters, _):
                return "\(parameters)"
            case let .requestCompositeParameters(bodyParameters, _, urlParameters):
                return "\(bodyParameters)\(urlParameters)"
            default:
                return ""
            }
        }
        return "\(URL(fileURLWithPath: path, relativeTo: baseURL).absoluteString)?\(parameter(task: task))"
    }
    
    public func request() -> Single<Response> {
        return Network.provider.rx.request(.target(self))
    }
    
    public func request<T: Codable>(_ type: T.Type,
                                    atKeyPath keyPath: String? = nil,
                                    decoder: JSONDecoder = .init()) -> Single<T> {
        return request().mapObject(type, atKeyPath: keyPath, decoder: decoder)
    }
    
    public func cachedObject<T: Codable>(_ type: T.Type,
                                         completion: @escaping (T) -> Void) -> Single<Self> {
        do {
            if let entry = try Network.storage?.entry(ofType: type, forKey: cachedKey) {
                completion(entry.object)
            }
        } catch let error {
            debugPrint("Load cached object fail:", error)
        }
        return Single.just(self)
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType: TargetType {
    public func request<T: Codable>(_ type: T.Type,
                                    atKeyPath keyPath: String? = nil,
                                    decoder: JSONDecoder = .init()) -> Single<T> {
        return flatMap { target -> Single<T> in
            return target.request(type, atKeyPath: keyPath, decoder: decoder).storeCachedObject(for: target)
        }
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapObject<T: Codable>(_ type: T.Type,
                                      atKeyPath keyPath: String? = nil,
                                      decoder: JSONDecoder = .init()) -> Single<T> {
        return flatMap { response -> Single<T> in
            do {
                return Single.just(try response.map(type, atKeyPath: keyPath, using: decoder))
            } catch let error {
                debugPrint("Response map error:", error)
                if let object = try? decoder.decode(type, from: "{}".data(using: .utf8)!) {
                    return Single.just(object)
                }
                else if let object = try? decoder.decode(type, from: "[{}]".data(using: .utf8)!) {
                    return Single.just(object)
                }
                return Single.error(error)
            }
        }
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType: Codable {
    public func storeCachedObject(for target: TargetType) -> Single<ElementType> {
        return flatMap { object -> Single<ElementType> in
            do {
                try Network.storage?.setObject(object, forKey: target.cachedKey)
            } catch let error {
                debugPrint("Store cached object fail:", error)
            }
            return Single.just(object)
        }
    }
}
