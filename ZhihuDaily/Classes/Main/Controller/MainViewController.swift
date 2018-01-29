//
//  MainViewController.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/3.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import SDCycleScrollView
import Kingfisher
import SnapKit
import MJRefresh

class MainViewController: UIViewController {
    
    static var leftMenuWidth = UIScreen.width * 3 / 5
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: view.bounds.width + MainViewController.leftMenuWidth, height: view.bounds.height)
        scrollView.contentOffset = CGPoint(x: MainViewController.leftMenuWidth, y: 0)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        fd_prefersNavigationBarHidden = true
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
        
        let menuVC = MenuViewController()
        menuVC.view.frame = CGRect(x: 0, y: 0, width: MainViewController.leftMenuWidth, height: view.bounds.height)
        addChildViewController(menuVC)
        scrollView.addSubview(menuVC.view)
        
        let homeVC = HomeViewController()
        homeVC.menuButtonDidSelectHandler = { [weak self] (sender) in
            let point = sender.isSelected ? CGPoint.zero : CGPoint(x: MainViewController.leftMenuWidth, y: 0)
            self.map({
                $0.scrollView.setContentOffset(point, animated: true)
            })
        }
        homeVC.view.frame = CGRect(x: MainViewController.leftMenuWidth, y: 0, width: UIScreen.width, height: UIScreen.height)
        addChildViewController(homeVC)
        scrollView.addSubview(homeVC.view)
    }
}

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let homeVC = childViewControllers.last as! HomeViewController
        homeVC.setMenuButtonSelected(scrollView.contentOffset.x == 0)
    }
}
