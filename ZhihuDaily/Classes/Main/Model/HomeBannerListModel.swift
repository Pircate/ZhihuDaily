//
//  HomeBannerListModel.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation

struct HomeBannerListModel: Codable {
    let recent: [HomeBannerRecentModel]
}

struct HomeBannerRecentModel: Codable {
    let newsID: Int
    let url: String
    let thumbnail: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case newsID = "news_id"
        case url = "url"
        case thumbnail = "thumbnail"
        case title = "title"
    }
}
