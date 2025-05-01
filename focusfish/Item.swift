//
//  Item.swift
//  focusfish
//
//  Created by Abby Li on 5/1/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
