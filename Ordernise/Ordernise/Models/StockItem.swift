//
//  StockItem.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import Foundation
import SwiftData

@Model
class StockItem {
    var id: UUID = UUID()
    var name: String = ""
    var quantityAvailable: Int = 0
    var price: Double = 0.0
    var cost: Double = 0.0
    var currency: Currency?
    
    // Custom field values storage
    var attributes: [String: String] = [:]
    
    @Relationship(deleteRule: .nullify)
    var category: Category?

    @Relationship(deleteRule: .nullify, inverse: \OrderItem.stockItem)
    var orderItems: [OrderItem]?

    init(
        id: UUID = UUID(),
        name: String = "",
        quantityAvailable: Int = 0,
        price: Double = 0.0,
        cost: Double = 0.0,
        currency: Currency? = nil,
        attributes: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.quantityAvailable = quantityAvailable
        self.price = price
        self.cost = cost
        self.currency = currency
        self.attributes = attributes
    }
}
