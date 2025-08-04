//
//  OrderStatus+Extensions.swift
//  Ordernise
//
//  Created by Aaron Strickland on 29/07/2025.
//

import Foundation
import SwiftUI

extension OrderStatus {
    /// Returns the list of order statuses that are enabled in Settings
    static var enabledCases: [OrderStatus] {
        // Get enabled statuses from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "enabledOrderStatuses"),
           let enabledStatusStrings = try? JSONDecoder().decode([String].self, from: data) {
            return OrderStatus.allCases.filter { enabledStatusStrings.contains($0.rawValue) }
        }
        
        // Default: return all cases if no settings found
        return OrderStatus.allCases
    }
    
    /// Check if a specific status is enabled
    var isEnabled: Bool {
        Self.enabledCases.contains(self)
    }
    
    /// Returns the appropriate color for displaying this order status
    var statusColor: Color {
        switch self {
        case .received: return .blue
        case .pending: return .orange
        case .processing: return .purple
        case .shipped: return .cyan
        case .delivered: return .green
        case .fulfilled: return .green
        case .returned: return .yellow
        case .refunded: return .orange
        case .canceled: return .red
        case .failed: return .red
        case .onHold: return .gray
        }
    }
}
