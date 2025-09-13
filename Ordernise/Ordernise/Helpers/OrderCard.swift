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
                .fill((order.status ?? .received).statusColor.gradient)
                .frame(width: 20)
                .frame(minHeight: height)
                .cornerRadius(50, corners: [.topLeft, .bottomLeft])

            // Right content
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    // Left section
                    VStack(alignment: .leading, spacing: 4) {
                        
                        if let customerName = order.customerName {
                            Text(customerName)
                                .font(.headline)
                           
                        }
                        
                        
                        
                        if let items = order.items, !items.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(items, id: \.id) { item in
                                
                                        
                                        
                                        Text("\(item.quantity) x \(item.stockItem?.name ?? String(localized: "Unnamed Item"))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                      
                                      
                                      
                                    
                                }
                            }
                        }

                        Text((order.platform ?? .amazon).rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        
                   

                        
                    
                    }

                    Spacer()

                    // Right section
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "largecircle.fill.circle")
                            Text((order.status ?? .received).localizedTitle)
                            
                        }
                        .font(.caption)
                        .foregroundStyle((order.status ?? .received).statusColor)

                   

                        Spacer()
                   
                    }
                    .padding(.top, 1)
                }
                
                HStack{
                    Spacer()
                    let totalValue = (order.items ?? []).reduce(0.0) { total, item in
                        total + (item.stockItem?.price ?? 0.0) * Double(item.quantity)
                    }

                    if !(order.items ?? []).isEmpty {
                        Text("\(String(localized: "Order Total: "))\(totalValue, format: localeManager.currencyFormatStyle)")
                            .font(.footnote)
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






extension String {
    func capitalizedFirst() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}
