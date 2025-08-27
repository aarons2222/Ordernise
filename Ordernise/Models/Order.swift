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
    var id: UUID = UUID()
    var orderReceivedDate: Date = Date()
    var orderReference: String?
    var customerName: String?
    var status: OrderStatus?
    var platform: Platform?
    
    // Cost-related fields
    var shippingCost: Double = 0.0
    var sellingFees: Double = 0.0
    var transactionFees: Double = 0.0
    var otherCosts: Double = 0.0
    var additionalCosts: Double = 0.0
    var shippingCompany: String?
    var shippingMethod: String?
    var trackingReference: String?
    var customerShippingCharge: Double = 0.0
    var additionalCostNotes: String?
    var orderCompletionDate: Date?
    var deliveryMethod: DeliveryMethod?
    
    // Reminder settings
    var reminderEnabled: Bool?
    var reminderTimeBeforeCompletion: TimeInterval?
    var reminderNotificationId: String?
    
    // Financial metrics
    var revenue: Double = 0.0
    var profit: Double = 0.0
    
    // Additional notes
    var notes: String?

    // Custom field values storage
    var attributes: [String: String] = [:]

    @Relationship(deleteRule: .cascade)
    var items: [OrderItem]?

    init(
        id: UUID = UUID(),
        orderReceivedDate: Date = Date(),
        orderReference: String? = nil,
        customerName: String? = nil,
        status: OrderStatus? = nil,
        platform: Platform? = nil,
        items: [OrderItem]? = nil,
        shippingCost: Double = 0.0,
        sellingFees: Double = 0.0,
        transactionFees: Double = 0.0,
        otherCosts: Double = 0.0,
        customerShippingCharge: Double = 0.0,
        additionalCostNotes: String? = nil,
        orderCompletionDate: Date? = nil,
        deliveryMethod: DeliveryMethod? = nil,
        reminderEnabled: Bool? = nil,
        reminderTimeBeforeCompletion: TimeInterval? = nil,
        reminderNotificationId: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.orderReceivedDate = orderReceivedDate
        self.orderReference = orderReference
        self.customerName = customerName
        self.status = status
        self.platform = platform
        self.items = items
        self.shippingCost = shippingCost
        self.sellingFees = sellingFees
        self.transactionFees = transactionFees
        self.otherCosts = otherCosts
        self.customerShippingCharge = customerShippingCharge
        self.additionalCostNotes = additionalCostNotes
        self.orderCompletionDate = orderCompletionDate
        self.deliveryMethod = deliveryMethod
        self.reminderEnabled = reminderEnabled
        self.reminderTimeBeforeCompletion = reminderTimeBeforeCompletion
        self.reminderNotificationId = reminderNotificationId
        self.notes = notes
    }
    
    // MARK: - Computed Properties
    
    /// Total value of all items in the order
    var itemsTotal: Double {
        items?.reduce(0) { total, item in
            total + (item.stockItem?.price ?? 0) * Double(item.quantity)
        } ?? 0.0
    }
    
    
    var itemsCostTotal: Double {
        items?.reduce(0) { total, item in
            total + (item.stockItem?.cost ?? 0) * Double(item.quantity)
        } ?? 0.0
    }
    
    /// Total order value including items, shipping, and additional costs
    var totalValue: Double {
        itemsTotal + shippingCost + additionalCosts
    }
    
    /// Total cost of goods sold (for profit calculations)
    var totalCost: Double {
        let itemsCost = items?.reduce(0) { total, item in
            total + (item.stockItem?.cost ?? 0) * Double(item.quantity)
        } ?? 0.0
        return itemsCost + shippingCost + additionalCosts
    }
    
    /// Calculated net profit for this order (revenue - all costs)
    var calculatedProfit: Double {
        itemsTotal - totalCost
    }
}
