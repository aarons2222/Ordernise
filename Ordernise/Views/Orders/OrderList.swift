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

enum OrderFilter: String, CaseIterable {
    case received = "Received"
    case completed = "Completed"
    
    func matchesOrder(_ order: Order) -> Bool {
        switch self {
        case .received:
            return [.received, .pending, .processing, .shipped, .onHold].contains(order.status)
        case .completed:
            return [.delivered, .fulfilled, .canceled, .failed, .refunded, .returned].contains(order.status)
        }
    }
}

struct OrderList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Order.date, order: .reverse) private var orders: [Order]
    
    @State private var showingAddOrder = false
    @State private var confirmDelete = false
    @State private var selectedOrder: Order?
    @State private var orderToDelete: Order?
 
    @State private var selectedFilter: OrderFilter = .received
    @Binding var searchText: String
 
    
    var filteredOrders: [Order] {
        orders.filter { order in
            let matchesSearch = searchText.isEmpty || 
                order.customerName?.localizedCaseInsensitiveContains(searchText) == true ||
                order.platform.rawValue.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter = selectedFilter.matchesOrder(order)
            
            return matchesSearch && matchesFilter
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
                    buttonContent: "plus.circle",
                    isButtonImage: true,
                    showTrailingButton: true,
                    showLeadingButton: false,
                    onButtonTap: {
                   
                        showingAddOrder = true
                    }
                )
                
                

                
                
                SegmentedControl(
                    tabs: OrderFilter.allCases,
                    activeTab: $selectedFilter,
                    height: 35,
                    extraText: nil,
                    font: .callout,
                    activeTint: Color(UIColor.systemBackground),
                    inActiveTint: .gray.opacity(0.8)
                ) { size in
                    Capsule()
                        .fill(Color.appTint.gradient)
                        .padding(.horizontal, 10)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .padding(.horizontal)
              
                
                
                
                
                
                
                
                
                
                
                
                
                
          
                if orders.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Orders", systemImage: "bag", description: Text("Tap \(Image(systemName: "plus.circle")) to add your first order."))
                    Spacer()
                } else if filteredOrders.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass", description: Text("No orders match your search."))
                    Spacer()
                } else {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            ForEach(groupedOrders, id: \.0) { dateString, ordersForDate in
                                Section(header: sectionHeader(dateString)) {
                                    ForEach(ordersForDate) { order in
                                        
                                        
                                        
                                        OrderCardView(height: 90, order: order)
                                            .swipeActions {
                                             
                                                
                                                Action(symbolImage: "trash.fill", tint: .white, background: .red) { resetPosition in
                                                    orderToDelete = order
                                                    confirmDelete = true
                                                }
                                            }
                                            .onTapGesture {
                                                selectedOrder = order
                                            }
                                    }
                                }
                            }
                        }
                    }
                  
                }
            }
            
            .alert("Confirm deletion", isPresented: $confirmDelete, actions: {
                
                /// A destructive button that appears in red.
                Button(role: .destructive) {
                    if let order = orderToDelete {
                        deleteOrder(order)
                    }
                } label: {
                    Text("Delete")
                }
                
                /// A cancellation button that appears with bold text.
                Button("Cancel", role: .cancel) {
                    // Perform cancellation
                }
                
          
            }, message: {
                Text("This action cannot be undone")
            })
            

            .fullScreenCover(isPresented: $showingAddOrder) {
                
                ZStack{
                    Color(.systemBackground)
                           .ignoresSafeArea()
                    OrderDetailView(mode: .add)
                }
            }
            .fullScreenCover(item: $selectedOrder) { selectedOrder in
                ZStack{
                    Color(.systemBackground)
                           .ignoresSafeArea()
                    OrderDetailView(order: selectedOrder, mode: .view)
                }
            }

            
        }
    }
    
    private func sectionHeader(_ dateString: String) -> some View {
        HStack {
            Text(dateString)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private func deleteOrder(_ order: Order) {
        withAnimation {
            // Return items to stock if order is not fulfilled
            if order.status != .fulfilled {
                for orderItem in order.items {
                    if let stockItem = orderItem.stockItem {
                        stockItem.quantityAvailable += orderItem.quantity
                    }
                }
            }
            
            // Delete the order from the model context
            modelContext.delete(order)
            
            // Save changes to persist deletion
            do {
                try modelContext.save()
                print("✅ [OrderList] Order deleted successfully: \(order.id)")
            } catch {
                print("❌ [OrderList] Failed to delete order: \(error)")
            }
        }
    }
    
    private func deleteOrdersInSection(_ ordersInSection: [Order], at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let orderToDelete = ordersInSection[index]
                deleteOrder(orderToDelete)
            }
        }
    }
}

//#Preview {
//    OrderList()
//}
//
//



