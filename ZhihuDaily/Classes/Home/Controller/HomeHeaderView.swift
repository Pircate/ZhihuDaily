//
//  HomeHeaderView.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/2/10.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit

class HomeHeaderView: UIView {
    
    lazy var bannerView: BannerView = {
        let bannerView = BannerView()
        bannerView.pageControlBottomOffset = 40
        return bannerView
    }()
    
    lazy var marqueeView: MarqueeView = {
        let marqueeView = MarqueeView()
        return marqueeView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSubviews() {
        addSubview(bannerView)
        addSubview(marqueeView)
        
        bannerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(250)
        }
        
        marqueeView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(bannerView.snp.bottom)
            make.height.equalTo(50)
        }
    }
}
