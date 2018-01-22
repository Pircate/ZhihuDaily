//
//  HomeNewsListModel.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation
import HandyJSON

struct HomeNewsListModel: HandyJSON {
    var date: String?
    var stories: [HomeNewsModel]?
    var topStories: [HomeNewsModel]?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.topStories <-- "top_stories"
    }
}

struct HomeNewsModel: HandyJSON {
    var images: [String]?
    var type: Int?
    var id: String?
    var gaPrefix: String?
    var title: String?
    var image: String?
}
