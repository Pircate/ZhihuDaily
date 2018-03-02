//
//  HTTPLoggerPlugin.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/2.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import Moya
import Result

public struct HTTPLoggerPlugin: PluginType {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        debugPrint("-----start request-----")
        debugPrint("requestURL:", request.request?.url?.absoluteString ?? "")
        if let data = request.request?.httpBody {
            debugPrint("parameters:", String(data: data, encoding: .utf8) ?? "")
        }
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            debugPrint("-----request success-----")
            debugPrint("*********Response JSONString*********")
            do {
                debugPrint(try response.mapJSON())
            } catch {}
            debugPrint("*****************End*****************")
        case .failure:
            debugPrint("-----request failure-----")
        }
    }
}
