//
//  HomeNewsListModel.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import Foundation

struct HomeNewsListModel: Codable {
    let date: String
    let stories: [HomeNewsModel]
    let topStories: [HomeNewsModel]
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case stories = "stories"
        case topStories = "top_stories"
    }
}

struct HomeNewsModel: Codable {
    let images: [String]
    let id: String
    let title: String
    let image: String
}
