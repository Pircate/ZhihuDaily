//
//  MarqueeView.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/2/10.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import FSPagerView

class MarqueeViewCell: FSPagerViewCell {
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(hex: "#3A4A56")
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MarqueeView: UIView {
    
    public var titles: [String] = [] {
        didSet {
            guard titles.count > 0 else {
                return
            }
            pagerView.reloadData()
        }
    }
    
    public var didSelectItemHandler: ((Int) -> Void)?
    public var didClickMoreButtonHandler: (() -> Void)?
    
    private lazy var leftView: UIButton = {
        let leftView = UIButton(type: .custom)
        leftView.setBackgroundImage(UIImage(named: "home_marquee_left"), for: .normal)
        leftView.setTitle("信息", for: .normal)
        leftView.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        leftView.isUserInteractionEnabled = false
        return leftView
    }()
    
    private lazy var pagerView: FSPagerView = {
        let pagerView = FSPagerView()
        pagerView.scrollDirection = .vertical
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 5
        pagerView.itemSize = pagerView.bounds.size
        pagerView.register(MarqueeViewCell.self, forCellWithReuseIdentifier: "MarqueeViewCell")
        return pagerView
    }()
    
    private lazy var moreButton: UIButton = {
        let moreButton = UIButton(type: .custom)
        moreButton.setTitle("更多", for: .normal)
        moreButton.setTitleColor(UIColor(hex: "#121F3E"), for: .normal)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        moreButton.titleLabel?.alpha = 0.38
        moreButton.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        return moreButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        addSubview(leftView)
        addSubview(pagerView)
        addSubview(moreButton)
        
        leftView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 18))
        }
        
        pagerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(50)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(16)
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 14))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func moreButtonAction() {
        didClickMoreButtonHandler.map({
            $0()
        })
    }
}

extension MarqueeView: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return titles.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell: MarqueeViewCell = pagerView.dequeueReusableCell(withReuseIdentifier: "MarqueeViewCell", at: index) as! MarqueeViewCell
        cell.titleLabel.text = titles[index]
        return cell
    }
}

extension MarqueeView: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        didSelectItemHandler.map({
            $0(index)
        })
    }
}
