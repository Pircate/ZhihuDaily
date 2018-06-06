//
//  RxCocoaExtension.swift
//  ZhihuDaily
//
//  Created by GorXion on 2018/5/3.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import RxCocoa
import FSCycleScrollView

extension Reactive where Base: UIImageView {
    var webImage: Binder<String> {
        return Binder(base) { imageView, url in
            imageView.kf.setImage(with: URL(string: url))
        }
    }
}

extension Reactive where Base: FSCycleScrollView {
    var items: Binder<[(image: String, title: String)]> {
        return Binder(base) { cycleScrollView, items in
            cycleScrollView.dataSourceType = .both(items: items)
        }
    }
}
