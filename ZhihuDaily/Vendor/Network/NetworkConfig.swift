//
//  NetworkConfig.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/2.
//  Copyright © 2018年 adinnet. All rights reserved.
//

public enum NetworkEnvironment {
    case develop
    case product
    
    var baseUrl: String {
        switch self {
        case .develop:
            return "https://news-at.zhihu.com/api"
        default:
            return "https://www.lanqixinxikeji.com/api/public/index.php/api/Upload/doUpload"
        }
    }
    
    var uploadUrl: String {
        switch self {
        case .develop:
            return "http://wuliu.hsrich.cn/index.php/api/Upload/doUpload"
        default:
            return "http://wuliu.hsrich.cn/index.php/api/Upload/doUpload"
        }
    }
}
