//
//  FSCycleScrollView+Rx.swift
//  ZhihuDaily
//
//  Created by GorXion on 2018/5/15.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import RxCocoa
import FSCycleScrollView

extension Reactive where Base: FSCycleScrollView {
    
    var itemSelected: ControlEvent<Int> {
        return ControlEvent(events: Observable.create({ [weak base] (observer) -> Disposable in
            base?.selectItemAtIndex = { index in
                observer.onNext(index)
            }
            return Disposables.create()
        }))
    }
}
