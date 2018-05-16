//
//  Navigatable.swift
//  ZhihuDaily
//
//  Created by GorXion on 2018/5/16.
//  Copyright © 2018年 gaoX. All rights reserved.
//

protocol Navigatable {
    
    var navigator: UINavigationController? { get }
    
    func start(_ closure: (Self) -> Void)
}

extension Navigatable {
    
    var navigator: UINavigationController? {
        return UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    }
}
