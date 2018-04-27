//
//  HomeViewController.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import MJRefresh
import RxSwift
import RxCocoa

extension UIApplication {
    static var statusBarHeight: CGFloat {
        return shared.statusBarFrame.height
    }
}

class HomeViewController: BaseViewController {
    
    private let customNavigationBarHeight: CGFloat = 44
    private let tableHeaderViewHeight: CGFloat = 200
    private let pullDownHeight: CGFloat = 60

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.rowHeight = 80;
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorColor = UIColor(hex: "#eeeeee")
        tableView.register(HomeNewsRowCell.self, forCellReuseIdentifier: "HomeNewsRowCell")
        tableView.mj_footer = MJRefreshAutoFooter()
        return tableView
    }()
    
    private lazy var progressView: ProgressView = {
        let progressView = ProgressView(frame: CGRect(x: UIScreen.width / 2 - 60, y: 12, width: 20, height: 20))
        return progressView
    }()
    
    lazy var menuButton: UIButton = {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0, y: UIApplication.statusBarHeight + 6, width: 44, height: 32)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuBtnAction(sender:)), for: .touchUpInside)
        return menuBtn
    }()
    
    private let viewModel = HomeViewModel()
    private let refresh: PublishSubject<Void> = PublishSubject<Void>()
    
    lazy var bannerView: BannerView = {
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: tableHeaderViewHeight))
        bannerView.pageControlBottomOffset = 36
        bannerView.didSelectItemHandler = { [weak self] (index) in
            self.map({
                let model = $0.viewModel.bannerList[index]
                $0.push(NewsDetailViewController.self) {
                    $0.newsID = model.id ?? ""
                }
            })
        }
        return bannerView
    }()
    
    var menuButtonDidSelectHandler: ((UIButton) -> Void)?
    private var isLoadable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        addSubviews()
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
        
        navigation.bar.isHidden = false
        navigation.bar.shadowImage = UIImage()
        navigation.bar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.maxY, width: UIScreen.width, height: 44)
        view.addSubview(navigation.bar)
        navigation.bar.alpha = 0
        navigation.bar.backgroundColor = UIColor.global
        navigation.item.title = "今日要闻"
        navigation.bar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigation.bar.addSubview(progressView)
    }
    
    private func addSubviews() {
        
        disableAdjustsScrollViewInsets(tableView)
        view.addSubview(tableView)
        view.addSubview(menuButton)
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: tableHeaderViewHeight))
        tableHeaderView.addSubview(bannerView)
        tableView.tableHeaderView = tableHeaderView
    }
    
    @objc private func menuBtnAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let handler = menuButtonDidSelectHandler {
            handler(sender)
        }
    }
    
    public func setMenuButtonSelected(_ isSelected: Bool) {
        menuButton.isSelected = isSelected
    }
    
    private func bindViewModel() {
        
        let input = HomeViewModel.Input(refresh: refresh, loading: tableView.mj_footer.rx.refreshClosure)
        let output = viewModel.transform(input)
        
        output.bannerItems.map({
            $0.compactMap({$0.image})
        }).drive(bannerView.rx.imageDataSource).disposed(by: disposeBag)
        
        output.bannerItems.map({
            $0.compactMap({$0.title})
        }).drive(bannerView.rx.titleDataSource).disposed(by: disposeBag)
        
        output.items.map({ _ in }).drive(progressView.rx.stop).disposed(by: disposeBag)
        output.items.map({ _ in RefreshStatus.endFooterRefresh }).drive(tableView.rx.endRefreshing).disposed(by: disposeBag)
        
        output.items.drive(tableView.rx.items(dataSource: viewModel.dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(HomeNewsModel.self).subscribe { (event) in
            self.push(NewsDetailViewController.self) {
                $0.newsID = event.element?.id ?? ""
            }
        }.disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else {
            return nil
        }
        let header = UIView()
        header.backgroundColor = UIColor.global
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: customNavigationBarHeight))
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.text = viewModel.sectionTitles[section - 1]
        label.textAlignment = .center
        header.addSubview(label)
        return header
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
                if tableView.contentOffset.y > -pullDownHeight {
                    var frame = bannerView.frame
                    frame.origin.y = tableView.contentOffset.y
                    frame.size.height = tableHeaderViewHeight - tableView.contentOffset.y
                    bannerView.frame = frame
                }
                else {
                    bannerView.frame = CGRect(x: 0, y: -pullDownHeight, width: UIScreen.width, height: tableHeaderViewHeight + pullDownHeight)
                    tableView.contentOffset = CGPoint(x: 0, y: -pullDownHeight)
                }
                
                guard isLoadable else { return }
                let progress = tableView.panGestureRecognizer.translation(in: tableView).y / pullDownHeight
                progressView.progress = progress < 1.0 ? progress : 1.0
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
