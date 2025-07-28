//
//  OrderList.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct OrderList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Order.date, order: .reverse) private var orders: [Order]
    
    @State private var showingAddOrder = false
    @State private var selectedOrder: Order?
    @State private var searchText = ""
    
    var filteredOrders: [Order] {
        orders.filter { order in
            searchText.isEmpty || 
            order.customerName?.localizedCaseInsensitiveContains(searchText) == true ||
            order.platform.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedOrders: [(String, [Order])] {
        let grouped = Dictionary(grouping: filteredOrders) { order in
            // Format date to show just the date part for grouping
            DateFormatter.dateOnly.string(from: order.date)
        }
        
        // Sort groups by date (newest first)
        return grouped.sorted { first, second in
            guard let firstDate = DateFormatter.dateOnly.date(from: first.key),
                  let secondDate = DateFormatter.dateOnly.date(from: second.key) else {
                return false
            }
            return firstDate > secondDate
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderWithButton(
                    title: "Orders",
                    buttonImage: "plus.circle",
                    showButton: true
                ) {
                    showingAddOrder = true
                }
                
          
                if orders.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Orders", systemImage: "bag", description: Text("Tap + to add your first order."))
                    Spacer()
                } else if filteredOrders.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass", description: Text("No orders match your search."))
                    Spacer()
                } else {
                    List {
                        ForEach(groupedOrders, id: \.0) { dateString, ordersForDate in
                            Section(header: Text(dateString).font(.headline)) {
                                ForEach(ordersForDate) { order in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text(order.date, style: .time)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                    HStack {
                                                        Circle()
                                                            .fill(statusColor(for: order.status))
                                                            .frame(width: 8, height: 8)
                                                        Text(order.status.rawValue.capitalized)
                                                            .font(.caption)
                                                            .foregroundColor(statusColor(for: order.status))
                                                    }
                                                }
                                                
                                                HStack {
                                                    if let customerName = order.customerName, !customerName.isEmpty {
                                                        Text(customerName)
                                                            .font(.subheadline)
                                                            .foregroundColor(.primary)
                                                    } else {
                                                        Text("No customer name")
                                                            .font(.subheadline)
                                                            .foregroundColor(.secondary)
                                                            .italic()
                                                    }
                                                    Spacer()
                                                    Text(order.platform.rawValue)
                                                        .font(.caption)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 2)
                                                        .background(Color(.systemGray5))
                                                        .cornerRadius(4)
                                                }
                                                
                                                HStack {
                                                    Text("\(order.items.count) item\(order.items.count == 1 ? "" : "s")")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                    if !order.items.isEmpty {
                                                        let totalValue = order.items.reduce(0.0) { total, orderItem in
                                                            total + (orderItem.stockItem?.price ?? 0.0) * Double(orderItem.quantity)
                                                        }
                                                        Text(totalValue, format: .currency(code: "GBP"))
                                                            .font(.caption)
                                                            .fontWeight(.semibold)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedOrder = order
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteOrdersInSection(ordersForDate, at: indexSet)
                                }
                            }
                        }
                    }
                  
                }
            }
//            .sheet(isPresented: $showingAddOrder) {
//                OrderDetailView(mode: .add)
//            }
//            .sheet(item: $selectedOrder) { selectedOrder in
//                OrderDetailView(order: selectedOrder, mode: .view)
//            }
//
            
            .fullScreenCover(isPresented: $showingAddOrder) {
                OrderDetailView(mode: .add)
            }
            .fullScreenCover(item: $selectedOrder) { selectedOrder in
                OrderDetailView(order: selectedOrder, mode: .view)
            }

            
        }
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .received: return .blue
        case .pending: return .orange
        case .fulfilled: return .green
        case .canceled: return .red
        }
    }
    
    private func deleteOrdersInSection(_ ordersInSection: [Order], at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let orderToDelete = ordersInSection[index]
                modelContext.delete(orderToDelete)
            }
        }
    }
}

#Preview {
    OrderList()
}
