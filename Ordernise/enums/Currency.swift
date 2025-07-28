//
//  CURRENCY.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import Foundation

enum Currency: String, Codable, Identifiable, CaseIterable {
    var id: String { rawValue }

    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"
    case cny = "CNY"
    case inr = "INR"
}
