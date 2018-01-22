//
//  UIColorExtension.swift
//  FirstJapaneseLife
//
//  Created by G-Xi0N on 2017/12/13.
//  Copyright © 2017年 G-Xi0N. All rights reserved.
//

import Foundation

extension UIColor {
    
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }
    
    open class var global: UIColor {
        return UIColor(hex: "#1296db")
    } // #1296db

    open class var lightText: UIColor {
        return UIColor(hex: "#BCBCBC")
    } // #BCBCBC

    open class var darkText: UIColor {
        return UIColor(hex: "#666666")
    } // #666666

    open class var hairline: UIColor {
        return UIColor(hex: "#E5E5E5")
    } // #E5E5E5
}
