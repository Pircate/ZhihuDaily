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
    
    let subject: BehaviorSubject<HomeNewsListModel>
    let bannerSubject: BehaviorSubject<[HomeNewsModel]>
    let loadingStatus: BehaviorSubject<LoadingStatus>
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
        subject = BehaviorSubject(value: HomeNewsListModel())
        bannerSubject = BehaviorSubject(value: [])
        loadingStatus = BehaviorSubject(value: .none)
        items = Driver.never()
        bannerItems = Driver.never()
    }
    
    func requestLatestNewsList() {
        provider.rx.request(.latestNews).mapObject(HomeNewsListModel.self).subscribe(onSuccess: { (response) in
            self.loadingStatus.onNext(.end)
            self.date = response.date
            self.sectionTitles.removeAll()
            self.sections.removeAll()
            self.subject.onNext(response)
            self.bannerList = response.topStories ?? []
            self.bannerSubject.onNext(response.topStories ?? [])
        }, onError: nil).disposed(by: disposeBag)
    }
    
    func requestBeforeNewsList() {
        guard let date = date else { return }
        provider.rx.request(.beforeNews(date: date)).mapObject(HomeNewsListModel.self).subscribe(onSuccess: { (response) in
            self.loadingStatus.onNext(.end)
            response.date.map({
                self.date = $0
                self.sectionTitles.append($0)
            })
            self.subject.onNext(response)
        }, onError: nil).disposed(by: disposeBag)
    }
    
    func bindToViews(bannerView: BannerView, tableView: UITableView) {
        
        items = subject.map({
            self.sections.append(HomeNewsSection(items: $0.stories ?? []))
            return self.sections
        }).asDriver(onErrorJustReturn: [])
        
        bannerItems = bannerSubject.asDriver(onErrorJustReturn: [])
        
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
