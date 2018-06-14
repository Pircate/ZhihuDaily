//
//  HomeViewController.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import MJRefresh
import Delegated
import Hero
import FSCycleScrollView
import RxSwift
import RxCocoa
import RxSwiftX

extension UIApplication {
    
    static var statusBarHeight: CGFloat {
        return shared.statusBarFrame.height
    }
}

final class HomeViewController: BaseViewController {
    
    var didSelectMenuButton = Delegated<Bool, Void>()
    
    private let customNavigationBarHeight: CGFloat = 44
    private let tableHeaderViewHeight: CGFloat = 200
    private let pullDownHeight: CGFloat = 60

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds).chain
            .estimatedSectionFooterHeight(0)
            .separatorColor(UIColor(hex: "#eeeeee"))
            .register(HomeNewsRowCell.self, forCellReuseIdentifier: "HomeNewsRowCell").build
        tableView.mj_footer = MJRefreshAutoFooter()
        disableAdjustsScrollViewInsets(tableView)
        return tableView
    }()
    
    lazy var dataSource: RxTableViewSectionedReloadProxy<HomeNewsSection> = {
        let dataSource = RxTableViewSectionedReloadProxy<HomeNewsSection>(configureCell: { (ds, tv, ip, item) -> HomeNewsRowCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "HomeNewsRowCell", for: ip) as! HomeNewsRowCell
            cell.update(item)
            return cell
        }, heightForRowAtIndexPath: { _, _, _ in
            return 100
        }, heightForHeaderInSection: { _, section in
            guard section > 0 else { return CGFloat.leastNormalMagnitude }
            return 44
        }, viewForHeaderInSection: { proxy, _, section in
            guard section > 0 else { return nil }
            let titleLabel = UILabel().chain
                .frame(x: 0, y: 0, width: UIScreen.width, height: 44)
                .backgroundColor(UIColor.global)
                .systemFont(ofSize: 16)
                .textColor(UIColor.white)
                .textAlignment(.center)
                .text(proxy[section].model).build
            return titleLabel
        })
        return dataSource
    }()
    
    private lazy var progressView: ProgressView = {
        ProgressView(frame: CGRect(x: UIScreen.width / 2 - 60, y: 12, width: 20, height: 20))
    }()
    
    lazy var menuButton: UIButton = {
        UIButton(type: .custom).chain
            .frame(x: 0, y: UIApplication.statusBarHeight + 6, width: 44, height: 32)
            .image(#imageLiteral(resourceName: "menu"), for: .normal).build
    }()
    
    lazy var bannerView: FSCycleScrollView = {
        let bannerView = FSCycleScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: tableHeaderViewHeight))
        bannerView.isInfinite = true
        bannerView.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)
        bannerView.automaticSlidingInterval = 5
        return bannerView
    }()
    
    private let viewModel = HomeViewModel()
    private let refresh: PublishSubject<Void> = PublishSubject<Void>()
    fileprivate var isLoadable = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildNavigation()
        buildSubviews()
        bindViewModel()
        refresh.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.bringSubview(toFront: navigation.bar)
        view.bringSubview(toFront: menuButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private
    
    private func buildNavigation() {
        
        navigation.bar.chain
            .isHidden(false)
            .frame(x: 0, y: UIApplication.shared.statusBarFrame.maxY, width: UIScreen.width, height: 44)
            .alpha(0)
            .backgroundColor(UIColor.global)
            .titleTextAttributes([.foregroundColor: UIColor.white])
            .shadowImage(UIImage()).addSubview(progressView)
        navigation.bar.subviews.first?.clipsToBounds = true
        view.addSubview(navigation.bar)
        navigation.item.title = "今日要闻"
    }
    
    private func buildSubviews() {
        
        view.addSubview(tableView)
        view.addSubview(menuButton)
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: tableHeaderViewHeight))
        tableHeaderView.addSubview(bannerView)
        tableView.tableHeaderView = tableHeaderView
    }
    
    private func bindViewModel() {
        
        let input = HomeViewModel.Input(refresh: refresh, loading: tableView.mj_footer.rx.refreshing)
        let output = viewModel.transform(input)

        output.bannerItems.drive(bannerView.rx.items).disposed(by: disposeBag)
        
        output.items.map({ _ in }).drive(progressView.rx.stop).disposed(by: disposeBag)
        output.items.map({ _ in }).drive(tableView.mj_footer.rx.endRefreshing).disposed(by: disposeBag)
        
        output.items.drive(tableView.rx.items(proxy: dataSource)).disposed(by: disposeBag)
        
        bannerView.rx.itemSelected.map({ self.viewModel.bannerList[$0] }).bind(to: rx.pushDetail).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asDriver().drive(tableView.rx.deselectRow(animated: true)).disposed(by: disposeBag)
        tableView.rx.modelSelected(HomeNewsModel.self).asDriver().drive(rx.pushDetail).disposed(by: disposeBag)
        
        bindMenuTap()
        bindDragging()
        bindContentOffset()
    }
    
    private func bindMenuTap() {
        let menuTap = menuButton.rx.tap.map(to: !self.menuButton.isSelected).shareOnce()
        menuTap.bind(to: menuButton.rx.isSelected).disposed(by: disposeBag)
        menuTap.bind(to: rx.didSelectMenuButton).disposed(by: disposeBag)
    }
    
    private func bindDragging() {
        tableView.rx.willBeginDragging
            .map(to: self.tableView.contentOffset == CGPoint.zero)
            .bind(to: rx.isLoadable).disposed(by: disposeBag)
        
        tableView.rx.didEndDragging.bind(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if self.progressView.progress >= 1.0 {
                self.progressView.startLoading()
                self.refresh.onNext(())
            } else {
                self.progressView.progress = 0
            }
            self.isLoadable = false
        }).disposed(by: disposeBag)
    }
    
    private func bindContentOffset() {
        tableView.rx.contentOffset.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self] offset in
            guard let `self` = self else { return }
            if offset.y > 0 {
                let alpha = offset.y / (self.tableHeaderViewHeight - UIApplication.statusBarHeight - self.navigation.bar.frame.height)
                self.navigation.bar.alpha = alpha
                self.progressView.progress = 0
            } else {
                self.navigation.bar.alpha = 0
                if offset.y >= -60 {
                    var frame = self.bannerView.frame
                    frame.origin.y = offset.y
                    frame.size.height = self.tableHeaderViewHeight - offset.y
                    self.bannerView.frame = frame
                    
                    guard self.isLoadable else { return }
                    let progress = -offset.y / 60
                    self.progressView.progress = progress < 1.0 ? progress : 1.0
                } else {
                    self.bannerView.frame = CGRect(x: 0, y: -60, width: UIScreen.width, height: self.tableHeaderViewHeight + 60)
                    self.tableView.contentOffset = CGPoint(x: 0, y: -60)
                }
            }
            guard self.tableView.numberOfSections > 0 else { return }
            if offset.y > self.tableHeaderViewHeight - UIApplication.statusBarHeight + self.tableView.rect(forSection: 0).height {
                self.navigation.bar.frame.origin.y = -44.0 + UIApplication.statusBarHeight
                self.navigation.bar.titleTextAttributes = [.foregroundColor: UIColor.white.alpha(0)]
                self.tableView.contentInset = UIEdgeInsets(top: UIApplication.statusBarHeight, left: 0, bottom: 0, right: 0)
            } else {
                self.navigation.bar.frame.origin.y = UIApplication.statusBarHeight
                self.navigation.bar.titleTextAttributes = [.foregroundColor: UIColor.white]
                self.tableView.contentInset = UIEdgeInsets.zero
            }
        }).disposed(by: disposeBag)
    }
}

extension Reactive where Base == HomeViewController {
    
    var isLoadable: Binder<Bool> {
        return Binder(base) { vc, isLoadable in
            vc.isLoadable = isLoadable
        }
    }
    
    var pushDetail: Binder<HomeNewsModel> {
        return Binder(base) { vc, model in
            vc.navigationController?.hero.isEnabled = true
            vc.navigationController?.hero.navigationAnimationType = .auto
            NewsDetailViewController().start {
                $0.newsID = model.id
                $0.heroID = model.id
            }
        }
    }
    
    var didSelectMenuButton: Binder<Bool> {
        return Binder(base) { vc, isSelected in
            vc.didSelectMenuButton.call(isSelected)
        }
    }
}
