//
//  OrderStatus.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import Foundation

enum OrderStatus: String, Codable, Identifiable, CaseIterable {
    var id: String { rawValue }

    case received       // Order has been recorded
    case pending        // Waiting for payment or confirmation
    case processing     // Being prepared/packed
    case shipped        // Handed over to carrier
    case delivered      // Reached customer
    case fulfilled      // Successfully completed (alternative to delivered)
    case returned       // Sent back by customer
    case refunded       // Payment returned to customer
    case canceled       // Manually or automatically canceled
    case failed         // Payment or processing failure
    case onHold         // Temporarily paused
}
