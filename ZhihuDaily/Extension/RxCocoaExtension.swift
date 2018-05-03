//
//  RxCocoaExtension.swift
//  ZhihuDaily
//
//  Created by GorXion on 2018/5/3.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {
    var deselect: Binder<IndexPath> {
        return Binder(base) { tableView, indexPath in
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
