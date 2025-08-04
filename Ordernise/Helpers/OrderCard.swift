//
//  OrderCard.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import SwiftUI

struct OrderCardView: View {
  
    let height: CGFloat
    
    @StateObject private var localeManager = LocaleManager.shared

    var order: Order

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar
            Rectangle()
                .fill(order.status.statusColor.gradient)
                .frame(width: 20)
                .frame(minHeight: height)
                .cornerRadius(50, corners: [.topLeft, .bottomLeft])

            // Right content
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    // Left section
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if let customerName = order.customerName {
                            Text(customerName)
                                .font(.headline)
                           
                        }
                        
                        
                        
                        if !order.items.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(order.items, id: \.id) { item in
                                    HStack {
                                        
                                        
                                        Text("\(item.quantity) x \(item.stockItem?.name ?? "Unnamed Item")")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                      
                                      
                                      
                                    }
                                }
                            }
                        }

                        
                        
                   

                        
                   
                    
                    }

                    Spacer()

                    // Right section
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "largecircle.fill.circle")
                            Text(order.status.rawValue.capitalizedFirst())
                        }
                        .font(.caption)
                        .foregroundStyle(order.status.statusColor)

                        Text(order.platform.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)

                        
                        let totalValue = order.items.reduce(0.0) { total, item in
                            total + (item.stockItem?.price ?? 0.0) * Double(item.quantity)
                        }

                        if !order.items.isEmpty {
                            Text("Order Total: \(totalValue, format: localeManager.currencyFormatStyle)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                     
                    }
                }
            }
            .padding()
            .frame(minHeight: height)
            .background(.thinMaterial)
            .cornerRadius(10, corners: [.topRight, .bottomRight])
        }
        .padding(.horizontal)
    }
}






extension Double {
    func asCurrency(_ code: String = "GBP") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.locale = Locale.current // Optional: customize for region
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
extension String {
    func capitalizedFirst() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}
