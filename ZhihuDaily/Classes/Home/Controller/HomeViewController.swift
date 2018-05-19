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

extension UIApplication {
    
    static var statusBarHeight: CGFloat {
        return shared.statusBarFrame.height
    }
}

final class HomeViewController: BaseViewController {
    
    private let customNavigationBarHeight: CGFloat = 44
    private let tableHeaderViewHeight: CGFloat = 200
    private let pullDownHeight: CGFloat = 60

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds).chain
            .delegate(self)
            .rowHeight(100)
            .estimatedSectionHeaderHeight(0)
            .estimatedSectionFooterHeight(0)
            .separatorColor(UIColor(hex: "#eeeeee"))
            .register(HomeNewsRowCell.self, forCellReuseIdentifier: "HomeNewsRowCell").build
        tableView.mj_footer = MJRefreshAutoFooter()
        return tableView
    }()
    
    private lazy var progressView: ProgressView = {
        ProgressView(frame: CGRect(x: UIScreen.width / 2 - 60, y: 12, width: 20, height: 20))
    }()
    
    lazy var menuButton: UIButton = {
        UIButton(type: .custom).chain
            .frame(x: 0, y: UIApplication.statusBarHeight + 6, width: 44, height: 32)
            .image(#imageLiteral(resourceName: "menu"), for: .normal)
            .addTarget(self, action: #selector(menuBtnAction(sender:)), for: .touchUpInside).build
    }()
    
    private let viewModel = HomeViewModel()
    private let refresh: PublishSubject<Void> = PublishSubject<Void>()
    
    lazy var bannerView: FSCycleScrollView = {
        let bannerView = FSCycleScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: tableHeaderViewHeight))
        bannerView.isInfinite = true
        bannerView.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)
        bannerView.automaticSlidingInterval = 5
        return bannerView
    }()
    
    var didSelectMenuButton = Delegated<UIButton, Void>()
    private var isLoadable = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupSubviews()
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
    
    private func setupNavigationItem() {
        
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
    
    private func setupSubviews() {
        
        disableAdjustsScrollViewInsets(tableView)
        view.addSubview(tableView)
        view.addSubview(menuButton)
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: tableHeaderViewHeight))
        tableHeaderView.addSubview(bannerView)
        tableView.tableHeaderView = tableHeaderView
    }
    
    @objc private func menuBtnAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        didSelectMenuButton.call(sender)
    }
    
    public func setMenuButtonSelected(_ isSelected: Bool) {
        menuButton.isSelected = isSelected
    }
    
    private func bindViewModel() {
        
        let input = HomeViewModel.Input(refresh: refresh, loading: tableView.mj_footer.rx.refreshClosure)
        let output = viewModel.transform(input)

        output.bannerItems.drive(bannerView.rx.items).disposed(by: disposeBag)
        
        output.items.map({ _ in }).drive(progressView.rx.stop).disposed(by: disposeBag)
        output.items.map({ _ in RefreshStatus.endFooterRefresh }).drive(tableView.rx.endRefreshing).disposed(by: disposeBag)
        
        output.items.drive(tableView.rx.items(dataSource: viewModel.dataSource)).disposed(by: disposeBag)
        
        bannerView.rx.itemSelected.map({ self.viewModel.bannerList[$0] }).bind(to: rx.pushDetail).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asDriver().drive(tableView.rx.deselect).disposed(by: disposeBag)
        tableView.rx.modelSelected(HomeNewsModel.self).asDriver().drive(rx.pushDetail).disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }
        let titleLabel = UILabel().chain
            .frame(x: 0, y: 0, width: UIScreen.width, height: customNavigationBarHeight)
            .backgroundColor(UIColor.global)
            .systemFont(ofSize: 16)
            .textColor(UIColor.white)
            .textAlignment(.center).build
        if viewModel.sectionTitles.count >= section {
            titleLabel.text = viewModel.sectionTitles[section - 1]
        }
        return titleLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else {
            return CGFloat.leastNormalMagnitude
        }
        return customNavigationBarHeight
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == tableView {
            if tableView.contentOffset.y > 0 {
                let alpha = tableView.contentOffset.y / (tableHeaderViewHeight - UIApplication.statusBarHeight - navigation.bar.frame.height)
                navigation.bar.alpha = alpha
                progressView.progress = 0
            }
            else {
                navigation.bar.alpha = 0
                if tableView.contentOffset.y >= -pullDownHeight {
                    var frame = bannerView.frame
                    frame.origin.y = tableView.contentOffset.y
                    frame.size.height = tableHeaderViewHeight - tableView.contentOffset.y
                    bannerView.frame = frame
                    
                    guard isLoadable else { return }
                    let progress = -tableView.contentOffset.y / pullDownHeight
                    progressView.progress = progress < 1.0 ? progress : 1.0
                }
                else {
                    bannerView.frame = CGRect(x: 0, y: -pullDownHeight, width: UIScreen.width, height: tableHeaderViewHeight + pullDownHeight)
                    tableView.contentOffset = CGPoint(x: 0, y: -pullDownHeight)
                }
                
                
            }
            guard tableView.numberOfSections > 0 else { return }
            if tableView.contentOffset.y > tableHeaderViewHeight - UIApplication.statusBarHeight + tableView.rect(forSection: 0).height {
                navigation.bar.frame.origin.y = -44.0 + UIApplication.statusBarHeight
                navigation.bar.titleTextAttributes = [.foregroundColor: UIColor.white.alpha(0)]
                tableView.contentInset = UIEdgeInsets(top: UIApplication.statusBarHeight, left: 0, bottom: 0, right: 0)
            }
            else {
                navigation.bar.frame.origin.y = UIApplication.statusBarHeight
                navigation.bar.titleTextAttributes = [.foregroundColor: UIColor.white]
                tableView.contentInset = UIEdgeInsets.zero
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if tableView.contentOffset == CGPoint.zero {
            isLoadable = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if progressView.progress >= 1.0 {
            progressView.startLoading()
            refresh.onNext(())
        }
        else {
            progressView.progress = 0
        }
        isLoadable = false
    }
}
