//
//  HomeViewModel.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxDataSources
import Moya
import RxSwiftX

typealias HomeNewsSection = SectionModel<String, HomeNewsModel>

class HomeViewModel {
    
    struct Input {
        let refresh: Observable<Void>
        let loading: ControlEvent<Void>
    }
    
    struct Output {
        let bannerItems: Driver<[(image: String, title: String)]>
        let items: Driver<[HomeNewsSection]>
    }
    
    var bannerList: [HomeNewsModel] = []
    
    func transform(_ input: Input) -> Output {
        
        var sections: [HomeNewsSection] = []
        
        let refresh = input.refresh.flatMap { _ in
            NewsAPI.latestNews.cache.request()
                .map(HomeNewsListModel.self)
                .asObservable()
                .catchError({ error in
                    Observable.empty()
                })
            }.shareOnce()
        
        let bannerItems = refresh.map({
            $0.topStories
        }).do(onNext: { (banners) in
            self.bannerList = banners
        }).map({
            $0.compactMap({ (image: $0.image, title: $0.title) })
        }).asDriver(onErrorJustReturn: [])
        
        let source1 = refresh.map({ response -> [HomeNewsSection] in
            sections = [HomeNewsSection(model: response.date, items: response.topStories)]
            return sections
        })
        
        let source2 = input.loading.flatMap {
            NewsAPI.beforeNews(date: sections.last?.model ?? "")
                .request()
                .map(HomeNewsListModel.self)
                .map({ response -> [HomeNewsSection] in
                    sections.append(HomeNewsSection(model: response.date, items: response.stories))
                    return sections
                })
                .asObservable()
                .catchErrorJustReturn([])
        }
        
        let items = Observable.merge(source1, source2).asDriver(onErrorJustReturn: [])
        
        return Output(bannerItems: bannerItems, items: items)
    }
}
