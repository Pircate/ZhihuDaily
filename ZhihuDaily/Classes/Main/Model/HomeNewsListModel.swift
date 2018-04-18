//
//  HomeNewsListModel.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation

struct HomeNewsListModel: Codable {
    var date: String?
    var stories: [HomeNewsModel]?
    var topStories: [HomeNewsModel]?
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case stories = "stories"
        case topStories = "top_stories"
    }
}

struct HomeNewsModel: Codable {
    var images: [String]?
    var id: Int?
    var title: String?
    var image: String?
}
