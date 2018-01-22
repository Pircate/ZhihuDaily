//
//  NewsDetailModel.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation
import HandyJSON

struct NewsDetailModel: HandyJSON {
    var body: String?
    var image_source: String?
    var title: String?
    var image: String?
    var share_url: String?
    var js: [String]?
    var ga_prefix: String?
    var images: [String]?
    var type: String?
    var id: String?
    var css: [String]?
}
