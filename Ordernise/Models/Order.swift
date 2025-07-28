//
//  Order.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import Foundation
import SwiftData

@Model
class Order {
    var id: UUID
    var date: Date
    var customerName: String?
    var status: OrderStatus
    var platform: Platform
    var attributes: [String: String]

    @Relationship(deleteRule: .cascade)
    var items: [OrderItem]

    init(
        id: UUID = UUID(),
        date: Date,
        customerName: String? = nil,
        status: OrderStatus = .pending,
        platform: Platform = .custom,
        attributes: [String: String] = [:],
        items: [OrderItem] = []
    ) {
        self.id = id
        self.date = date
        self.customerName = customerName
        self.status = status
        self.platform = platform
        self.attributes = attributes
        self.items = items
    }
}
