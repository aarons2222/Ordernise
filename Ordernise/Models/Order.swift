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
    var orderReference: String?
    var customerName: String?
    var status: OrderStatus
    var platform: Platform
    var attributes: [String: String]
    
    // Cost-related fields
    var shippingCost: Double
    var sellingFees: Double
    var additionalCosts: Double
    var shippingMethod: String?
    var trackingReference: String?
    var additionalCostNotes: String?

    @Relationship(deleteRule: .cascade)
    var items: [OrderItem]

    init(
        id: UUID = UUID(),
        date: Date,
        orderReference: String? = nil,
        customerName: String? = nil,
        status: OrderStatus = .received,
        platform: Platform = .amazon,
        attributes: [String: String] = [:],
        items: [OrderItem] = [],
        shippingCost: Double = 0.0,
        sellingFees: Double = 0.0,
        additionalCosts: Double = 0.0,
        shippingMethod: String? = nil,
        trackingReference: String? = nil,
        additionalCostNotes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.customerName = customerName
        self.orderReference = orderReference
        self.status = status
        self.platform = platform
        self.attributes = attributes
        self.items = items
        self.shippingCost = shippingCost
        self.sellingFees = sellingFees
        self.additionalCosts = additionalCosts
        self.shippingMethod = shippingMethod
        self.trackingReference = trackingReference
        self.additionalCostNotes = additionalCostNotes
    }
    
    // MARK: - Computed Properties
    
    /// Total value of all items in the order
    var itemsTotal: Double {
        items.reduce(0) { total, item in
            total + (item.stockItem?.price ?? 0) * Double(item.quantity)
        }
    }
    
    /// Total order value including items, shipping, and additional costs
    var totalValue: Double {
        itemsTotal + shippingCost + additionalCosts
    }
    
    /// Total cost of goods sold (for profit calculations)
    var totalCost: Double {
        let itemsCost = items.reduce(0) { total, item in
            total + (item.stockItem?.cost ?? 0) * Double(item.quantity)
        }
        return itemsCost + shippingCost + additionalCosts
    }
    
    /// Net profit for this order (revenue - all costs)
    var profit: Double {
        itemsTotal - totalCost
    }
}
