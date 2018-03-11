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
import HandyJSON

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapObject<T: HandyJSON>(_ type: T.Type) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(JSONDeserializer.deserializeFrom(json: try response.mapString()) ?? T())
        }
    }
}

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
    let loadingStatus: BehaviorSubject<LoadingStatus>
    var items: Driver<[HomeNewsSection]>
    var date: String?
    var sectionTitles: [String] = []
    var bannerList: [HomeNewsModel] = []
    var sections: [HomeNewsSection] = []
    
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<HomeNewsSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<HomeNewsSection>(configureCell: { (ds, tv, ip, item) -> HomeNewsRowCell in
            let cell: HomeNewsRowCell = tv.dequeueReusableCell(withIdentifier: "HomeNewsRowCell", for: ip) as! HomeNewsRowCell
            cell.model = item
            return cell
        })
        return dataSource
    }()
    
    private let provider = HTTPProvider<HomeTarget>()
    private let disposeBag = DisposeBag()
    
    init() {
        subject = BehaviorSubject(value: HomeNewsListModel())
        loadingStatus = BehaviorSubject(value: .none)
        items = Driver.never()
    }
    
    func requestLatestNewsList() {
        provider.rx.request(.latestNews).mapObject(HomeNewsListModel.self).subscribe(onSuccess: { (response) in
            self.loadingStatus.onNext(.end)
            self.date = response.date
            self.sectionTitles.removeAll()
            self.sections.removeAll()
            self.subject.onNext(response)
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
        
        items.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        subject.subscribe(onNext: { (model) in
            model.topStories.map({
                self.bannerList = $0
                bannerView.imageDataSource = $0.flatMap({
                    $0.image
                })
                bannerView.titleDataSource = $0.flatMap({
                    $0.title
                })
            })
        }).disposed(by: disposeBag)
    }
}
