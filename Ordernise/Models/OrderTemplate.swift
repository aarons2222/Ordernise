//
//  OrderTemplate.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import Foundation
import SwiftData

@Model
class OrderTemplate {
    var id: UUID
    var name: String
    var dateCreated: Date
    var isDefault: Bool
    
    // Order form data (excluding customer-specific data like name and items)
    var status: OrderStatus
    var platform: Platform
    var customAttributes: [String: String]
    
    init(
        id: UUID = UUID(),
        name: String,
        status: OrderStatus,
        platform: Platform,
        customAttributes: [String: String] = [:],
        dateCreated: Date = Date(),
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
        self.isDefault = isDefault
        self.status = status
        self.platform = platform
        self.customAttributes = customAttributes
    }
}
