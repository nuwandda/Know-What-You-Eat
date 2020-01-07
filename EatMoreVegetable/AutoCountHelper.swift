

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
