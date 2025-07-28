//
//  Platform.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import Foundation

enum Platform: String, Codable, Identifiable, CaseIterable {
    var id: String { rawValue }

    case ebay = "eBay"
    case vinted = "Vinted"
    case shopify = "Shopify"
    case etsy = "Etsy"
    case amazon = "Amazon"
    case depop = "Depop"
    case poshmark = "Poshmark"
    case carboot = "Carboot Sale"
    case marketplace = "Facebook Marketplace"
    case gumtree = "Gumtree"
    case custom = "Custom"
}
