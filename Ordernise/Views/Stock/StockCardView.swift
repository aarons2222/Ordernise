//
//  OrderCardView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 29/07/2025.
//

//
//  CategoryCard.swift
//  Ordernise
//
//  Created by Aaron Strickland on 29/07/2025.
//


import SwiftUI





struct StockItemCard: View {
 
    var item: StockItem
    let height: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            // Left date section
           Rectangle()
                .foregroundStyle(.clear)
                .frame(width: 20, height: height)
                .padding(.vertical)
                .background(item.category?.color.gradient ?? Color.appTint.gradient)
            .cornerRadius(50, corners: [.topLeft, .bottomLeft])

            HStack {
            
            
            
            // Right details section
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
             
                if let category = item.category{
               
                    
                    LabelValue(label: "Category: ", value: category.name)
                    
                }
                
                
                
                LabelValue(label: "Price: ", value: "\(item.price)")

            
                }
                
                
                Spacer()
                
                Text("\(item.quantityAvailable)")
                    .font(.body)
                    .padding(5)
                    
                    .background(
                       Capsule().fill(quantityColor(item.quantityAvailable).gradient)
                            .frame(minWidth: 25)
                    )
                    .foregroundColor(.white)
                
                
              
            }
            .frame(height: height)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
            
            .cornerRadius(15, corners: [.topRight, .bottomRight])
        }
        .padding(.horizontal)
    }
    
    private func quantityColor(_ qty: Int) -> Color {
        if qty < 5 {
            return .red
        } else if qty < 10 {
            return .orange
        } else if qty < 15 {
            return .yellow
        } else {
            return .green
        }
    }

}

struct LabelValue: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
         
        }
    }
}


import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

//
//
//
//
//struct StockItemCard: View {
//    var item: StockItem
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Left side - Item name and basic info
//            VStack(alignment: .leading, spacing: 4) {
//                Text(item.name)
//                    .font(.headline)
//                    .fontWeight(.medium)
//                    .foregroundColor(.primary)
//                    .lineLimit(2)
//                
//                // Quantity with colored background
//                HStack(spacing: 4) {
//                    Image(systemName: quantityIcon(item.quantityAvailable))
//                        .font(.caption2)
//                        .foregroundColor(quantityColor(item.quantityAvailable))
//                    
//                    Text("\(item.quantityAvailable)")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(quantityColor(item.quantityAvailable))
//                }
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(
//                    RoundedRectangle(cornerRadius: 6)
//                        .fill(quantityColor(item.quantityAvailable).opacity(0.1))
//                )
//            }
//            
//            Spacer()
//            
//            // Right side - Quantity and price in a clean layout
//            VStack(alignment: .trailing, spacing: 8) {
//          
//                
//                // Price
//                Text(item.price, format: .currency(code: item.currency.rawValue.uppercased()))
//                    .font(.subheadline)
//                    .fontWeight(.medium)
//                    .foregroundColor(.primary)
//            }
//        }
//        .padding()
//        .frame(minHeight: 72)
//        .cardBackground()
//        .padding(.horizontal, 20)
//    }
//
//    private func quantityColor(_ qty: Int) -> Color {
//        if qty == 0 { return .red }
//        if qty <= 10 { return .orange }
//        return .green
//    }
//    
//    private func quantityIcon(_ qty: Int) -> String {
//        if qty == 0 { return "exclamationmark.triangle.fill" }
//        if qty <= 10 { return "exclamationmark.circle.fill" }
//        return "checkmark.circle.fill"
//    }
//}
