//
//  DeliveryMethod.swift
//  Ordernise
//
//  Created by Aaron Strickland on 18/08/2025.
//

import Foundation

enum DeliveryMethod: String, CaseIterable, Identifiable, Codable {
    case collected = "Pick up"
    case shipped = "Delivery"

    var id: String { self.rawValue }
    
    var localizedName: String {
        switch self {
        case .collected:
            return String(localized: "Pick up")
        case .shipped:
            return String(localized: "Delivery")
        }
    }
}
