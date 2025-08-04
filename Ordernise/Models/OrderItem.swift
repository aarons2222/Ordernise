//
//  OrderItem.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI

import Foundation
import SwiftData

@Model
class OrderItem {
    var id: UUID
    var quantity: Int
    var attributes: [String: String]

    @Relationship
    var stockItem: StockItem?

    @Relationship(inverse: \Order.items)
    var order: Order?

    init(id: UUID = UUID(), quantity: Int, stockItem: StockItem? = nil, attributes: [String: String] = [:]) {
        self.id = id
        self.quantity = quantity
        self.stockItem = stockItem
        self.attributes = attributes
    }
}
