//
//  NewsDetailModel.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation

struct NewsDetailModel: Codable {
    let body: String
    let title: String
    let image: String
    let js: [String]
    let id: String
    let css: [String]
}
