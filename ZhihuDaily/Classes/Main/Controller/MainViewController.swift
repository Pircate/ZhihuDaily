//
//  MainViewController.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/3.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import MJRefresh
import RxSwift

class MainViewController: UIViewController {
    
    private var leftMenuWidth = UIScreen.width * 3 / 5
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.contentSize = CGSize(width: view.bounds.width + leftMenuWidth, height: view.bounds.height)
        scrollView.contentOffset = CGPoint(x: leftMenuWidth, y: 0)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigation.bar.isHidden = true
        addSubviews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addSubviews() {
        
        disableAdjustsScrollViewInsets(scrollView)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let menuVC = MenuViewController()
        menuVC.view.frame = CGRect(x: 0, y: 0, width: leftMenuWidth, height: view.bounds.height)
        addChild(menuVC)
        scrollView.addSubview(menuVC.view)
        
        let homeVC = HomeViewController()
        homeVC.didSelectMenuButton.delegate(to: self, with: { (self, isSelected) in
            let point = isSelected ? CGPoint.zero : CGPoint(x: self.leftMenuWidth, y: 0)
            self.scrollView.setContentOffset(point, animated: true)
        })
        homeVC.view.frame = CGRect(x: leftMenuWidth, y: 0, width: UIScreen.width, height: UIScreen.height)
        addChild(homeVC)
        scrollView.addSubview(homeVC.view)
        
        scrollView.rx.contentOffset
            .map({ $0.x == 0 })
            .asDriver(onErrorJustReturnClosure: false)
            .drive(homeVC.menuButton.rx.isSelected)
            .disposed(by: disposeBag)
    }
}
