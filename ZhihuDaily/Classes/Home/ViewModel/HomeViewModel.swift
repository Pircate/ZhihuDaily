//
//  HomeViewModel.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Moya
import RxNetwork

enum LoadingStatus {
    case none, begin, isLoading, end
}

struct HomeNewsSection {
    var items: [HomeNewsModel]
}

extension HomeNewsSection: SectionModelType {
    
    typealias Item = HomeNewsModel
    
    init(original: HomeNewsSection, items: [HomeNewsModel]) {
        self = original
        self.items = items
    }
}

class HomeViewModel {
    
    struct Input {
        let refresh: Observable<Void>
        let loading: ControlEvent<RefreshStatus>
    }
    
    struct Output {
        let bannerImages: Driver<[String]>
        let bannerTitles: Driver<[String]>
        let items: Driver<[HomeNewsSection]>
    }

    private let relay: BehaviorRelay<[HomeNewsSection]> = BehaviorRelay(value: [])
    private var date: String = ""
    private var sections: [HomeNewsSection] = []
    private let disposeBag = DisposeBag()
    
    var sectionTitles: [String] = []
    var bannerList: [HomeNewsModel] = []
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<HomeNewsSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<HomeNewsSection>(configureCell: { (ds, tv, ip, item) -> HomeNewsRowCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "HomeNewsRowCell", for: ip) as! HomeNewsRowCell
            cell.model = item
            return cell
        })
        return dataSource
    }()
    
    func transform(_ input: Input) -> Output {
        
        let result = input.refresh.flatMap { _ in
            self.requestLatestNews()
            }.share(replay: 1)
        
        let bannerItems = result.map({
            $0.topStories ?? []
        }).do(onNext: { (banners) in
            self.bannerList = banners
        })
        
        let bannerImages = bannerItems.map({ $0.compactMap({ $0.image })}).asDriver(onErrorJustReturn: [])
        let bannerTitles = bannerItems.map({ $0.compactMap({ $0.title })}).asDriver(onErrorJustReturn: [])
        
        let items = relay.asDriver(onErrorJustReturn: [])
        
        result.map({
            HomeNewsSection(items: $0.stories ?? [])
        }).subscribe(onNext: { [weak self] (section) in
            guard let `self` = self else { return }
            self.sections = [section]
            self.relay.accept(self.sections)
        }).disposed(by: disposeBag)
        
        input.loading.flatMap { _ in
            self.requestBeforeNews()
            }.subscribe(onNext: { [weak self] (section) in
                guard let `self` = self else { return }
                self.sections.append(section)
                self.relay.accept(self.sections)
            }).disposed(by: disposeBag)
        
        return Output(bannerImages: bannerImages, bannerTitles: bannerTitles, items: items)
    }
    
    private func requestLatestNews() -> Single<HomeNewsListModel> {
        return HomeTarget.latestNews.request(HomeNewsListModel.self).do(onSuccess: { [weak self] (model) in
            guard let `self` = self else { return }
            self.date = model.date ?? ""
            self.sectionTitles.removeAll()
        }).catchError({ error in
            Single.error(error)
        })
    }
    
    private func requestBeforeNews() -> Single<HomeNewsSection> {
        return HomeTarget.beforeNews(date: self.date).request(HomeNewsListModel.self).do(onSuccess: { [weak self] (model) in
            guard let `self` = self else { return }
            self.date = model.date ?? ""
            self.sectionTitles.append(self.date)
        }).map({
            HomeNewsSection(items: $0.stories ?? [])
        }).catchError({ error in
            Single.error(error)
        })
    }
}
