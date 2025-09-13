//
//  ShippingCompany.swift
//  Ordernise
//
//  Created by Aaron Strickland on 18/08/2025.
//

import Foundation

enum ShippingCompany: String, Codable, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    // UK/Europe
    case royalMail = "Royal Mail"
    case evri = "Evri"
    case yodel = "Yodel"
    case dpd = "DPD"
    case dhl = "DHL"
    case ups = "UPS"
    case fedex = "FedEx"
    case postNL = "PostNL"
    case laPoste = "La Poste"
    case deutschePost = "Deutsche Post"
    
    // North America
    case usps = "USPS"
    case canadaPost = "Canada Post"
    
    // Other
    case custom = "Custom"
}
