//
//  DeliveryMethod.swift
//  Ordernise
//
//  Created by Aaron Strickland on 02/08/2025.
//

import SwiftUI


enum DeliveryMethod: String, CaseIterable, Identifiable, Codable {
    case collected = "Collected"
    case delivered = "Delivered"

    var id: String { self.rawValue }
    
    var localizedName: String {
        switch self {
        case .collected:
            return String(localized: "Collected")
        case .delivered:
            return String(localized: "Delivered")
        }
    }
}

struct DeliveryPicker: View {
    @Binding var selection: DeliveryMethod

    var body: some View {
    
     

            HStack(spacing: 30) {
                ForEach(DeliveryMethod.allCases) { method in
                    Button(action: {
                        selection = method
                    }) {
                        buttonLabel(for: method)
                    }
                    .buttonStyle(PlainButtonStyle()) // optional to remove default button styling
                }
            } 
      
        .padding()
    }

    @ViewBuilder
    private func buttonLabel(for method: DeliveryMethod) -> some View {
        HStack(spacing: 8) {
            Image(systemName: selection == method ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(selection == method ? Color.appTint : Color.gray)
           
              

            Text(method.localizedName)
             
        }
        .padding(8)
        .cornerRadius(8)
    }
}

