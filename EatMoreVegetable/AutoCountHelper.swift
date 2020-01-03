//
//  AutoCountHelper.swift
//  EatMoreVegetable
//
//  Created by Rapsodo Mobile 6 on 13.12.2019.
//  Copyright © 2019 Rapsodo Mobile 6. All rights reserved.
//

import Foundation


class AutoCountHelper {
    static let shared = AutoCountHelper()
    var autoCount = 0
    var autoCountData = 0

    func updateAutocount() -> Int {
        autoCount += 1
        return autoCount
    }
    
    func updateAutoCountData() {
        autoCountData += 1
    }
}
