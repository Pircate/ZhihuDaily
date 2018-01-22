//
//  HomeBannerListModel.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation
import HandyJSON

struct HomeBannerListModel: HandyJSON {
    var recent: [HomeBannerRecentModel]?
}

struct HomeBannerRecentModel: HandyJSON {
    var newsID: Int?
    var url: String?
    var thumbnail: String?
    var title: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &newsID, name: "news_id")
    }
}
