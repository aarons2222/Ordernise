//
//  Item.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
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
