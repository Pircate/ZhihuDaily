//
//  HomeViewController.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import MJRefresh
import SDCycleScrollView

extension UIApplication {
    static var statusBarHeight: CGFloat {
        return shared.statusBarFrame.height
    }
}

class HomeViewController: BaseViewController {
    
    static let customNavigationBarHeight: CGFloat = 30
    static let tableHeaderViewHeight: CGFloat = 200

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80;
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorColor = UIColor(hex: "#eeeeee")
        tableView.register(HomeNewsRowCell.self, forCellReuseIdentifier: "cellID")
        return tableView
    }()
    
    lazy var navBar: UIView = {
        let navBar = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIApplication.statusBarHeight + HomeViewController.customNavigationBarHeight))
        navBar.backgroundColor = UIColor.global
        navBar.alpha = 0
        return navBar
    }()
    
    lazy var navTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: UIApplication.statusBarHeight, width: UIScreen.width, height: HomeViewController.customNavigationBarHeight))
        label.textColor = UIColor.white
        label.text = "今日要闻"
        label.textAlignment = .center
        return label
    }()
    
    lazy var menuButton: UIButton = {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0, y: UIApplication.statusBarHeight, width: 44, height: 32)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuBtnAction(sender:)), for: .touchUpInside)
        return menuBtn
    }()
    
    lazy var cycleScrollView: SDCycleScrollView = {
        let cycleScrollView = SDCycleScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: HomeViewController.tableHeaderViewHeight))
        cycleScrollView.delegate = self
        return cycleScrollView
    }()
    
    var menuButtonDidSelectHandler: ((UIButton) -> Void)?
    
    var bannerList: [HomeNewsModel] = []
    var dataSource: [[HomeNewsModel]] = []
    var date: String?
    var sectionTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupTableViewRefresh()
        tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addSubviews() {
        
        disableAdjustsScrollViewInsets(tableView)
        view.addSubview(tableView)
        view.addSubview(navBar)
        view.addSubview(navTitleLabel)
        view.addSubview(menuButton)
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: HomeViewController.tableHeaderViewHeight))
        tableHeaderView.addSubview(cycleScrollView)
        tableView.tableHeaderView = tableHeaderView
    }
    
    private func setupTableViewRefresh() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            if let strongSelf = self {
                strongSelf.requestLatestNewsList()
            }
        })
        
        tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: { [weak self] in
            if let strongSelf = self {
                strongSelf.requestBeforeNewsList()
            }
        })
    }
    
    private func requestLatestNewsList() {
        HomeComponent().requestLatestNewsList(cache: { (model) in
            self.sectionTitles.removeAll()
            self.date = model?.date
            if let bannerList = model?.topStories {
                self.bannerList = bannerList;
                self.cycleScrollView.imageURLStringsGroup = bannerList.flatMap({
                    $0.image
                })
                self.cycleScrollView.titlesGroup = bannerList.flatMap({
                    $0.title
                })
            }
            if let newsList = model?.stories {
                self.dataSource = [newsList]
            }
            self.tableView.reloadData()
        }, success: { (model) in
            if self.tableView.mj_header.isRefreshing {
                self.tableView.mj_header.endRefreshing()
            }
            self.sectionTitles.removeAll()
            self.date = model?.date
            if let bannerList = model?.topStories {
                self.bannerList = bannerList;
                self.cycleScrollView.imageURLStringsGroup = bannerList.flatMap({
                    $0.image
                })
                self.cycleScrollView.titlesGroup = bannerList.flatMap({
                    $0.title
                })
            }
            if let newsList = model?.stories {
                self.dataSource = [newsList]
            }
            self.tableView.reloadData()
        }) { (error) in
            
        }
    }
    
    private func requestBeforeNewsList() {
        guard let date = self.date else { return }
        HomeComponent().requestBeforeNewsList(date: date, success: { (model) in
            if self.tableView.mj_footer.isRefreshing {
                self.tableView.mj_footer.endRefreshing()
            }
            if let date = model?.date {
                self.date = date
                self.sectionTitles.append(date)
            }
            if let newsList = model?.stories {
                self.dataSource.append(newsList)
            }
            self.tableView.reloadData()
        }) { (error) in
            
        }
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
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as! HomeNewsRowCell
        let model = dataSource[indexPath.section][indexPath.row]
        cell.model = model
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else {
            return nil
        }
        let header = UIView()
        header.backgroundColor = UIColor.global
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: HomeViewController.customNavigationBarHeight))
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.text = sectionTitles[section - 1]
        label.textAlignment = .center
        header.addSubview(label)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else {
            return CGFloat.leastNormalMagnitude
        }
        return HomeViewController.customNavigationBarHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.section][indexPath.row]
        push(NewsDetailViewController.self) {
            $0.newsID = model.id ?? ""
        }
    }
}

extension HomeViewController: SDCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        let model = bannerList[index]
        push(NewsDetailViewController.self) {
            $0.newsID = model.id ?? ""
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == tableView {
            if tableView.contentOffset.y > 0 {
                let alpha = tableView.contentOffset.y / HomeViewController.tableHeaderViewHeight
                navBar.alpha = alpha
            }
            else {
                if tableView.contentOffset.y > -40 {
                    var frame = cycleScrollView.frame
                    frame.origin.y = tableView.contentOffset.y
                    frame.size.height = HomeViewController.tableHeaderViewHeight - tableView.contentOffset.y
                    cycleScrollView.frame = frame
                }
                else {
                    cycleScrollView.frame = CGRect(x: 0, y: -40, width: UIScreen.width, height: HomeViewController.tableHeaderViewHeight + 40)
                    tableView.contentOffset = CGPoint(x: 0, y: -40)
                }
                cycleScrollView.adjustWhenControllerViewWillAppera()
            }
            guard tableView.numberOfSections > 0 else { return }
            if tableView.contentOffset.y > HomeViewController.tableHeaderViewHeight - UIApplication.statusBarHeight + tableView.rect(forSection: 0).height {
                navBar.frame.size.height = UIApplication.statusBarHeight
                navTitleLabel.isHidden = true
                tableView.contentInset = UIEdgeInsets(top: UIApplication.statusBarHeight, left: 0, bottom: 0, right: 0)
            }
            else {
                navTitleLabel.isHidden = false
                navBar.frame.size.height = HomeViewController.customNavigationBarHeight + UIApplication.statusBarHeight
                tableView.contentInset = UIEdgeInsets.zero
            }
        }
    }
}

