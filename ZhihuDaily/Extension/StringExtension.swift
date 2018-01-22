//
//  StringExtension.swift
//  iWeeB
//
//  Created by 高翔 on 2017/12/13.
//  Copyright © 2017年 GaoX. All rights reserved.
//

import Foundation

extension String {
    public var isBlank: Bool {
        return isEmpty || trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
