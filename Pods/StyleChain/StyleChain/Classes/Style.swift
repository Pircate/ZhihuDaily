//
//  Style.swift
//  StyleChain
//
//  Created by GorXion on 2018/5/8.
//

public protocol StyleCompatible {
    
    associatedtype CompatibleType
    
    var style: CompatibleType { get }
}

public extension StyleCompatible {
    
    public var style: Style<Self> {
        return Style(self)
    }
}

public struct Style<Base> {
    
    let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}
