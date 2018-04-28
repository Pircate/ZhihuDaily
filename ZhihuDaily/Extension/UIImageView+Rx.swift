//
//  UIImageView+Rx.swift
//  ZhihuDaily
//
//  Created by GorXion on 2018/4/27.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIImageView {
    var webImage: Binder<String> {
        return Binder(base) { imageView, url in
            imageView.kf.setImage(with: URL(string: url))
        }
    }
}
