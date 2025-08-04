//
//  Color+Extension.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//

import SwiftUI

extension Color {
    static var appTint: Color {
        let hex = UserDefaults.standard.string(forKey: "userTintHex") ?? "#007AFF"
        return Color(hex: hex) ?? .color1
    }
}
