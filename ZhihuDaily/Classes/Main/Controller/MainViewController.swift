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

class MainViewController: UIViewController {
    
    private var leftMenuWidth = UIScreen.width * 3 / 5
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.contentSize = CGSize(width: view.bounds.width + leftMenuWidth, height: view.bounds.height)
        scrollView.contentOffset = CGPoint(x: leftMenuWidth, y: 0)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        ay_navigationBar.isHidden = true
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
        addChildViewController(menuVC)
        scrollView.addSubview(menuVC.view)
        
        let homeVC = HomeViewController()
        homeVC.menuButtonDidSelectHandler = { [weak self] (sender) in
            self.map({
                let point = sender.isSelected ? CGPoint.zero : CGPoint(x: $0.leftMenuWidth, y: 0)
                $0.scrollView.setContentOffset(point, animated: true)
            })
        }
        homeVC.view.frame = CGRect(x: leftMenuWidth, y: 0, width: UIScreen.width, height: UIScreen.height)
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
