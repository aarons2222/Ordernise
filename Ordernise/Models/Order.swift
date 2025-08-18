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
    var orderReceivedDate: Date
    var orderReference: String?
    var customerName: String?
    var status: OrderStatus
    var platform: Platform
    
    // Cost-related fields
    var shippingCost: Double
    var sellingFees: Double
    var additionalCosts: Double
    var shippingMethod: String?
    var trackingReference: String?
    var customerShippingCharge: Double
    var additionalCostNotes: String?
    var orderCompletionDate: Date?
    var deliveryMethod: DeliveryMethod?
    
    // Financial metrics
    var revenue: Double
    var profit: Double

    // Custom field values storage
    var attributes: [String: String]

    @Relationship(deleteRule: .cascade)
    var items: [OrderItem]

    init(
        id: UUID = UUID(),
        orderReceivedDate: Date,
        orderReference: String? = nil,
        customerName: String? = nil,
        status: OrderStatus = .received,
        platform: Platform = .amazon,
        items: [OrderItem] = [],
        shippingCost: Double = 0.0,
        sellingFees: Double = 0.0,
        additionalCosts: Double = 0.0,
        shippingMethod: String? = nil,
        trackingReference: String? = nil,
        customerShippingCharge: Double = 0.0,
        additionalCostNotes: String? = nil,
        orderCompletionDate: Date? = nil,
        deliveryMethod: DeliveryMethod = .collected,
        revenue: Double = 0.0,
        profit: Double = 0.0,
        attributes: [String: String] = [:]
    ) {
        self.id = id
        self.orderReceivedDate = orderReceivedDate
        self.customerName = customerName
        self.orderReference = orderReference
        self.status = status
        self.platform = platform
        self.items = items
        self.shippingCost = shippingCost
        self.sellingFees = sellingFees
        self.additionalCosts = additionalCosts
        self.shippingMethod = shippingMethod
        self.trackingReference = trackingReference
        self.customerShippingCharge = customerShippingCharge
        self.additionalCostNotes = additionalCostNotes
        self.orderCompletionDate = orderCompletionDate
        self.deliveryMethod = deliveryMethod
        self.revenue = revenue
        self.profit = profit
        self.attributes = attributes
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
    
    /// Calculated net profit for this order (revenue - all costs)
    var calculatedProfit: Double {
        itemsTotal - totalCost
    }
}
