//
//  ConfigurableCell.swift
//  ConfigurableCell
//
//  Created by 高 on 2018/1/29.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit

protocol Configurable {
    var reuseIdentifier: String { get }
    var cellClass: AnyClass { get }
    var cellHeight: CGFloat { get }
    
    func update(cell: UITableViewCell)
    func cellItem<T>() -> T
}

protocol Updatable {
    associatedtype ViewData
    func update(viewData: ViewData)
}

extension Updatable {
    func update(viewData: ViewData) {}
}

struct Row<Cell> where Cell: Updatable, Cell: UITableViewCell {
    
    let viewData: Cell.ViewData
    let reuseIdentifier: String
    let cellClass: AnyClass = Cell.self
    var cellHeight: CGFloat = 44.0
    
    init(viewData: Cell.ViewData,
        reuseIdentifier: String = "\(Cell.classForCoder())",
        figureHeight: ((Cell.ViewData) -> CGFloat)? = nil) {
        
        self.viewData = viewData
        self.reuseIdentifier = reuseIdentifier
        figureHeight.flatMap({
            self.cellHeight = $0(viewData)
        })
    }
    
    func update(cell: UITableViewCell) {
        if let cell = cell as? Cell {
            cell.update(viewData: viewData)
        }
    }
    
    func cellItem<T>() -> T {
        guard let item = viewData as? T else { fatalError("Item type error") }
        return item
    }
}

extension Row: Configurable {}
