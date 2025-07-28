//
//  OrderStatus.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import Foundation

enum OrderStatus: String, Codable, Identifiable, CaseIterable {
    var id: String { rawValue }

    case received
    case pending
    case fulfilled
    case canceled
}
