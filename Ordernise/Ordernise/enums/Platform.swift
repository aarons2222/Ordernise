//
//  Platform.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import Foundation

enum Platform: String, Codable, Identifiable, CaseIterable {
    var id: String { rawValue }

    case amazon = "Amazon"
    case carboot = "Carboot Sale"
    case custom = "Custom"
    case depop = "Depop"
    case ebay = "eBay"
    case etsy = "Etsy"
    case marketplace = "Facebook Marketplace"
    case gumtree = "Gumtree"
    case numonday = "numonday"
    case poshmark = "Poshmark"
    case shopify = "Shopify"
    case vinted = "Vinted"
}
