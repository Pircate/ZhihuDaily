//
//  GXBaseComponent.swift
//  iWeeB
//
//  Created by 高翔 on 2017/11/23.
//  Copyright © 2017年 GaoX. All rights reserved.
//

import UIKit
import HandyJSON

struct DataResponse<T: HandyJSON>: HandyJSON {
    
    private var msg = ""
    private var code = ""
    private var data: Any?
    
    var success: Bool {
        return code == "200"
    }
    
    var message: String {
        return self.msg
    }
    
    var statusCode: String {
        return self.code
    }
    
    var model: T? {
        get {
            if let dict = data as? [String: Any] {
                return JSONDeserializer.deserializeFrom(dict: dict)
            }
            return nil
        }
    }
    
    var resultList: [T?]? {
        get {
            if let array = data as? [Any] {
                return JSONDeserializer.deserializeModelArrayFrom(array: array)
            }
            return nil
        }
    }
    
    var resultText: String? {
        get {
            return data as? String
        }
    }
}

struct Convertor<T: HandyJSON> {
    
    static func convertToResponse(json: String?) -> DataResponse<T> {
        return JSONDeserializer<DataResponse<T>>.deserializeFrom(json: json) ?? DataResponse<T>()
    }
}

class BaseComponent {
    
    private var requestCount = 0
    
    func startRequest<T: HandyJSON>(
        request: HTTPRequest,
        cache: ((T?) -> ())? = nil,
        success: @escaping (T?) -> (),
        failure: @escaping (Error?) -> ()) {
        
        if request.needsCache {
            if let cacheData = request.cacheData() as? Data {
                cache.map({
                    let json = String(data: cacheData, encoding: .utf8)
                    $0(JSONDeserializer<T>.deserializeFrom(json: json))
                })
            }
        }
        
        self.requestCount += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("-----start request-----")
        request.start(success: { (JSONString, otherInfo) in
            print("-----request success-----")
            self.requestCount -= 1
            if self.requestCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if request.needsCache {
                if let data = JSONString?.data(using: .utf8) {
                    request.saveDataToDisk(data: data)
                }
            }
            success(JSONDeserializer<T>.deserializeFrom(json: JSONString))
        }) { (error, otherInfo) in
            print("-----request failure-----")
            self.requestCount -= 1
            if self.requestCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            failure(error)
        }
    }
}
