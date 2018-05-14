//
//  Updatable.swift
//  Updatable
//
//  Created by 高 on 2018/1/29.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit

protocol Updatable {
 
    associatedtype Item
    
    func update(_ item: Item)
}
