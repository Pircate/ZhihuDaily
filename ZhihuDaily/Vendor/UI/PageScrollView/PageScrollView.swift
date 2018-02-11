//
//  PageScrollView.swift
//  GXPageScrollView
//
//  Created by GorXion on 2018/2/2.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit

protocol PageScrollViewDataSource: class {
    
    func numberOfItems(in pageScrollView: PageScrollView) -> Int
    
    func pageScrollView(_ pageScrollView: PageScrollView, itemForIndexAt index: Int) -> UIView
    
    func pageScrollView(_ pageScrollView: PageScrollView, titleForIndexAt index: Int) -> String
}

protocol PageScrollViewDelegate: class {
    
    func pageScrollView(_ pageScrollView: PageScrollView, didSelectItemAt index: Int)
    
    func pageScrollView(_ pageScrollView: PageScrollView, didScrollToItemAt index: Int)
}

extension PageScrollViewDelegate {
    func pageScrollView(_ pageScrollView: PageScrollView, didSelectItemAt index: Int) {}
    func pageScrollView(_ pageScrollView: PageScrollView, didScrollToItemAt index: Int) {}
}

class PageScrollView: UIView {
    
    private let kMenuHeight: CGFloat = 44.0
    
    public weak var dataSource: PageScrollViewDataSource?
    public weak var delegate: PageScrollViewDelegate?
    
    lazy var menuView: PageMenuView = {
        let menuView = PageMenuView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kMenuHeight))
        return menuView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: kMenuHeight, width: bounds.width, height: bounds.height - kMenuHeight))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private var titles: [String] = []
    private var items: [UIView] = []
    private var currentIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        bounds.size.width = UIScreen.width
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        menuView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: kMenuHeight)
        scrollView.frame = CGRect(x: 0, y: kMenuHeight, width: bounds.width, height: bounds.height - kMenuHeight)
    }
    
    private func addSubviews() {
        addSubview(menuView)
        addSubview(scrollView)
        menuView.didSelectItemHandler = { [weak self] (index) in
            self.map({
                $0.delegate?.pageScrollView($0, didSelectItemAt: index)
                $0.scrollView.setContentOffset(CGPoint(x: $0.scrollView.bounds.width * CGFloat(index), y: 0), animated: true)
            })
        }
    }
    
    public func reloadData() {
        
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfItems(in: self)
        guard count > 0 else { return }
        
        titles.removeAll()
        items.forEach({ $0.removeFromSuperview() })
        items.removeAll()
        for index in 0..<count {
            let title = dataSource.pageScrollView(self, titleForIndexAt: index)
            titles.append(title)
            let item = dataSource.pageScrollView(self, itemForIndexAt: index)
            items.append(item)
        }
        
        menuView.titles = titles
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(items.count), height: scrollView.bounds.height)
        items.enumerated().forEach({
            scrollView.addSubview($1)
            $1.frame = CGRect(x: scrollView.bounds.width * CGFloat($0), y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        })
        scrollView.contentOffset = CGPoint.zero
    }
}

extension PageScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetX = scrollView.contentOffset.x
        var pageIndex = Int(offsetX / bounds.width)
        let offset = Double(offsetX / bounds.width)
        let first = floor(offset)
        let last = offset - first
        
        if last > 0.5 {
            pageIndex = Int(ceil(offset))
        }
        
        if currentIndex != pageIndex {
            if pageIndex >= titles.count {
                pageIndex = titles.count - 1
            }
            if pageIndex < 0 {
                pageIndex = 0
            }
            if scrollView.isDragging {
                menuView.selectItem(at: pageIndex)
            }
            currentIndex = pageIndex
            delegate?.pageScrollView(self, didScrollToItemAt: pageIndex)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / bounds.width)
        menuView.selectItem(at: index)
    }
}
