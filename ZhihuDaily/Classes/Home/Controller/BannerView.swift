//
//  BannerView.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/2/10.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import FSPagerView

protocol BannerViewDelegate: class {
    func bannerView(_ bannerView: BannerView, didSelectItemAt index: Int)
}

extension BannerViewDelegate {
    func bannerView(_ bannerView: BannerView, didSelectItemAt index: Int) {}
}

class BannerView: UIView {

    public weak var delegate: BannerViewDelegate?
    
    public var placeholder: UIImage?
    
    public var imageDataSource: [String] = [] {
        didSet {
            guard imageDataSource.count > 0 else {
                return
            }
            pageControl.numberOfPages = imageDataSource.count
            pagerView.reloadData()
        }
    }
    
    public var titleDataSource: [String] = [] {
        didSet {
            guard titleDataSource.count > 0 else {
                return
            }
            pagerView.reloadData()
        }
    }
    
    public var showPageControl: Bool = true {
        didSet {
            pageControl.isHidden = showPageControl
        }
    }
    
    public var pageControlBottomOffset: CGFloat = 0 {
        didSet {
            pageControl.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: pageControlBottomOffset, right: 0)
        }
    }
    
    private lazy var pagerView: FSPagerView = {
        let pagerView = FSPagerView(frame: bounds)
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.itemSize = bounds.size
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 5
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        return pagerView
    }()
    
    private lazy var pageControl: FSPageControl = {
        let pageControl = FSPageControl(frame: CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 20))
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pagerView)
        addSubview(pageControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        pagerView.frame = bounds
        pagerView.itemSize = bounds.size
        pageControl.frame = CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 20)
    }
}

extension BannerView: FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageDataSource.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        if imageDataSource.count > index {
            let resource = URL(string: imageDataSource[index])
            cell.imageView?.kf.setImage(with: resource, placeholder: placeholder)
        }
        if titleDataSource.count > index {
            cell.textLabel?.text = titleDataSource[index]
        }
        return cell
    }
}

extension BannerView: FSPagerViewDelegate {
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        delegate?.bannerView(self, didSelectItemAt: index)
    }
}
