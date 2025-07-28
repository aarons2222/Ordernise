//
//  StockItem.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import Foundation
import SwiftData


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
    var id: UUID
    var name: String
    var quantityAvailable: Int
    var price: Double
    var cost: Double
    var currency: Currency
    var attributes: [String: String]

    @Relationship(deleteRule: .nullify, inverse: \OrderItem.stockItem)
    var orderItems: [OrderItem]?

    init(
        id: UUID = UUID(),
        name: String,
        quantityAvailable: Int,
        price: Double,
        cost: Double,
        currency: Currency = .usd,
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
