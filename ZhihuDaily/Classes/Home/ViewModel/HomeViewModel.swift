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
import CleanJSON
import RxSwift

typealias HomeNewsSection = SectionModel<String, HomeNewsModel>

extension Response {
    
    func mapObject<D: Decodable>(_ type: D.Type) throws -> D {
        return try CleanJSONDecoder().decode(type, from: data)
    }
}

extension ObservableType where E == Response {
    
    func mapObject<D: Decodable>(_ type: D.Type) -> Observable<D> {
        return map { response -> D in
            return try response.mapObject(type)
        }
    }
}

class HomeViewModel {
    
    struct Input {
        let refresh: Observable<Void>
        let loading: ControlEvent<Void>
    }
    
    struct Output {
        let bannerItems: Driver<[(image: String, title: String)]>
        let items: Driver<[HomeNewsSection]>
        let endRefresh: Driver<Void>
        let endMore: Driver<Void>
    }
    
    var bannerList: [HomeNewsModel] = []
    
    func transform(_ input: Input) -> Output {
        
        var sections: [HomeNewsSection] = []
        
        let refresh = input.refresh.flatMap { _ in
            NewsAPI.latestNews.cache.request()
                .mapObject(HomeNewsListModel.self)
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
        }).asDriver(onErrorJustReturn: [])
        
        let endRefresh = source1.map(to: ())
        
        let source2 = input.loading.flatMap {
            NewsAPI.beforeNews(date: sections.last?.model ?? "")
                .request()
                .map(HomeNewsListModel.self, using: CleanJSONDecoder())
                .map({ [HomeNewsSection(model: $0.date, items: $0.stories)] })
                .catchErrorJustReturn([])
            }.map({ section -> [HomeNewsSection] in
                sections += section
                return sections
            }).asDriver(onErrorJustReturn: [])
        
        let endMore = source2.map(to: ())
        
        let items = Driver.of(source1, source2).merge()
        
        return Output(bannerItems: bannerItems,
                      items: items,
                      endRefresh: endRefresh,
                      endMore: endMore)
    }
}
