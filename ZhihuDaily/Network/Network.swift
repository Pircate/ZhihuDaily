//
//  Network.swift
//  SwiftNetwork
//
//  Created by GorXion on 2018/4/17.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Moya
import Cache

extension TargetType {
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var headers: [String: String]? {
        return nil
    }
}

extension MoyaProvider {
    public convenience init(taskClosure: @escaping (TargetType) -> Task) {
        self.init(endpointClosure: { (target) -> Endpoint in
            MoyaProvider.defaultEndpointMapping(for: target).replacing(task: taskClosure(target))
        }, plugins: [NetworkIndicatorPlugin(), HTTPLoggerPlugin()])
    }
}

public final class Network {
    public static var taskClosure: (TargetType) -> Task = { $0.task }
    public static let provider = MoyaProvider<MultiTarget>(taskClosure: taskClosure)
    public static let storage = try? Storage(diskConfig: DiskConfig(name: "NetworkRequestCache"),
                                             memoryConfig: MemoryConfig())
}
