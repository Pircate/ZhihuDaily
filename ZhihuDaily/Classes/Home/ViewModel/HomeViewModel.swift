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
    
    let relay: BehaviorRelay<HomeNewsListModel>
    let bannerRelay: BehaviorRelay<[HomeNewsModel]>
    let loadingStatus: BehaviorRelay<LoadingStatus>
    var items: Driver<[HomeNewsSection]>
    var bannerItems: Driver<[HomeNewsModel]>
    var date: String?
    var sectionTitles: [String] = []
    var bannerList: [HomeNewsModel] = []
    var sections: [HomeNewsSection] = []
    
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<HomeNewsSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<HomeNewsSection>(configureCell: { (ds, tv, ip, item) -> HomeNewsRowCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "HomeNewsRowCell", for: ip) as! HomeNewsRowCell
            cell.model = item
            return cell
        })
        return dataSource
    }()
    
    private let provider = HTTPProvider<HomeTarget>()
    private let disposeBag = DisposeBag()
    
    init() {
        relay = BehaviorRelay(value: HomeNewsListModel())
        bannerRelay = BehaviorRelay(value: [])
        loadingStatus = BehaviorRelay(value: .none)
        items = Driver.never()
        bannerItems = Driver.never()
    }
    
    func requestLatestNewsList() {
        provider.request(.latestNews) { [weak self] (response: HomeNewsListModel) in
            self?.handleLatestResponse(response)
            }.subscribe(onSuccess: { [weak self] (response) in
                self?.loadingStatus.accept(.end)
                self?.handleLatestResponse(response)
            }, onError: nil).disposed(by: disposeBag)
    }
    
    func handleLatestResponse(_ response: HomeNewsListModel) {
        date = response.date
        sectionTitles.removeAll()
        sections.removeAll()
        relay.accept(response)
        bannerList = response.topStories ?? []
        bannerRelay.accept(response.topStories ?? [])
    }
    
    func requestBeforeNewsList() {
        guard let date = date else { return }
        provider.rx.request(.beforeNews(date: date)).mapObject(HomeNewsListModel.self).subscribe(onSuccess: { [weak self] (response) in
            self?.handleBeforeResponse(response)
        }, onError: nil).disposed(by: disposeBag)
    }
    
    func handleBeforeResponse(_ response: HomeNewsListModel) {
        loadingStatus.accept(.end)
        if let date = response.date {
            self.date = date
            sectionTitles.append(date)
        }
        relay.accept(response)
    }
    
    func bindToViews(bannerView: BannerView, tableView: UITableView) {
        
        items = relay.map({
            self.sections.append(HomeNewsSection(items: $0.stories ?? []))
            return self.sections
        }).asDriver(onErrorJustReturn: [])
        
        bannerItems = bannerRelay.asDriver(onErrorJustReturn: [])
        
        items.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        bannerItems.map({
            $0.flatMap({
                $0.image
            })
        }).drive(bannerView.rx.imageDataSource).disposed(by: disposeBag)
        
        bannerItems.map({
            $0.flatMap({
                $0.title
            })
        }).drive(bannerView.rx.titleDataSource).disposed(by: disposeBag)
    }
}
