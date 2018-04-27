//
//  MJRefresh+Rx.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/12.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import RxSwift
import RxCocoa
import MJRefresh

public enum RefreshStatus {
    case none
    case isHeaderRefreshing
    case endHeaderRefresh
    case isFooterRefreshing
    case endFooterRefresh
}

extension Reactive where Base: MJRefreshHeader {
    
    public var beginRefreshing: Binder<Void> {
        return Binder(self.base) { header, _ in
            header.beginRefreshing()
        }
    }
    
    public var refreshClosure: ControlEvent<RefreshStatus> {
        return ControlEvent(events: Observable.create({ (observer) -> Disposable in
            self.base.refreshingBlock = {
                observer.onNext(.isHeaderRefreshing)
            }
            return Disposables.create()
        }))
    }
}

extension Reactive where Base: MJRefreshFooter {
    
    public var beginRefreshing: Binder<Void> {
        return Binder(self.base) { footer, _ in
            footer.beginRefreshing()
        }
    }
    
    public var refreshClosure: ControlEvent<RefreshStatus> {
        return ControlEvent(events: Observable.create({ (observer) -> Disposable in
            self.base.refreshingBlock = {
                observer.onNext(.isFooterRefreshing)
            }
            return Disposables.create()
        }))
    }
}

extension Reactive where Base: UIScrollView {
    
    public var endRefreshing: Binder<RefreshStatus> {
        return Binder(self.base) { (scrollView, status) in
            switch status {
            case .endHeaderRefresh:
                scrollView.endHeaderRefreshing()
            case .endFooterRefresh:
                scrollView.endFooterRefreshing()
            default:
                break
            }
        }
    }
}

extension UIScrollView {
    
    func endHeaderRefreshing() {
        guard let mj_header = mj_header else { return }
        if mj_header.isRefreshing {
            mj_header.endRefreshing()
        }
    }
    
    func endFooterRefreshing() {
        guard let mj_footer = mj_footer else { return }
        if mj_footer.isRefreshing {
            mj_footer.endRefreshing()
        }
    }
}
