//
//  UITableViewExtension.swift
//  iWeeB
//
//  Created by 高翔 on 2017/12/4.
//  Copyright © 2017年 GaoX. All rights reserved.
//

import Foundation

extension UITableView {
    func setSeparatorInset(left: CGFloat, right: CGFloat) {
        separatorInset = UIEdgeInsetsMake(0, left, 0, right)
        layoutMargins = UIEdgeInsetsMake(0, left, 0, right)
        preservesSuperviewLayoutMargins = false
    }
}
