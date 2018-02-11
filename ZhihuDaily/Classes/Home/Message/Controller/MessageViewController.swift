//
//  MessageViewController.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/2/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit

class MessageViewController: BaseViewController {

    lazy var pageScrollView: PageScrollView = {
        let pageScrollView = PageScrollView()
        pageScrollView.dataSource = self
        pageScrollView.menuView.configureItemStyle(normalColor: UIColor(hex: "#3A4A56").alpha(0.4), selectedColor: UIColor(hex: "#3A4A56"), underlineColor: UIColor(hex: "#4381E8"))
        return pageScrollView
    }()
    
    lazy var titles: [String] = {
        let titles = ["物流消息", "还/收款通知", "起租通知"]
        return titles
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        loadSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadSubviews() {
        view.addSubview(pageScrollView)
        pageScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        pageScrollView.reloadData()
    }

}

extension MessageViewController: PageScrollViewDataSource {
    func numberOfItems(in pageScrollView: PageScrollView) -> Int {
        return titles.count
    }
    
    func pageScrollView(_ pageScrollView: PageScrollView, titleForIndexAt index: Int) -> String {
        return titles[index]
    }
    
    func pageScrollView(_ pageScrollView: PageScrollView, itemForIndexAt index: Int) -> UIView {
        return [UIView(), UIView(), UIView()][index]
    }
}
