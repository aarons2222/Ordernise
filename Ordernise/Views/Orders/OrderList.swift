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
    case inProgress = "In Progress"
    case completed = "Completed"
    
    // Localized display name for UI
    var localizedTitle: String {
        switch self {
        case .received:
            return String(localized: "Received")
        case .inProgress:
            return String(localized: "In Progress")
        case .completed:
            return String(localized: "Completed")
        }
    }
    
    func matchesOrder(_ order: Order) -> Bool {
        switch self {
        case .received:
            return [.received].contains(order.status)
        case .inProgress:
            return [.pending, .processing, .shipped, .onHold].contains(order.status)
        case .completed:
            return [.delivered, .fulfilled, .canceled, .failed, .refunded, .returned].contains(order.status)
        }
    }
}


struct OrderList: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @Query(sort: \Order.orderReceivedDate, order: .reverse) private var realOrders: [Order]
    
    private var allOrders: [Order] {
        if dummyDataManager.isDummyModeEnabled {
            return dummyDataManager.getDummyOrders()
        } else {
            return realOrders
        }
    }
    
    @State private var showingAddOrder = false
    @State private var confirmDelete = false
    @State private var selectedOrder: Order?
    @State private var orderToDelete: Order?
    @State private var showingOrderCalendar = false

 
    @State private var selectedFilter: OrderFilter = .received
    @Binding var searchText: String
    
    var filteredOrders: [Order] {
        // Filter by search text
        let searchFiltered = searchText.isEmpty ? allOrders : allOrders.filter { order in
            // Search in order details
            let orderMatches = order.customerName?.localizedCaseInsensitiveContains(searchText) == true ||
                              order.orderReference?.localizedCaseInsensitiveContains(searchText) == true ||
                              order.platform.rawValue.localizedCaseInsensitiveContains(searchText)
            
            // Search in order items (stock item names)
            let itemMatches = order.items.contains { orderItem in
                orderItem.stockItem?.name.localizedCaseInsensitiveContains(searchText) == true
            }
            
            return orderMatches || itemMatches
        }
        
        // Filter by selected status filter
        return searchFiltered.filter { order in
            selectedFilter.matchesOrder(order)
        }
    }
    
    var groupedOrders: [(String, [Order])] {
        let grouped = Dictionary(grouping: filteredOrders) { order in
            // Format date to show just the date part for grouping
            DateFormatter.dateOnly.string(from: order.orderReceivedDate)
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
    
    // Computed properties for order counts
    private var receivedOrdersCount: Int {
        let searchFiltered = searchText.isEmpty ? allOrders : allOrders.filter { order in
            order.customerName?.localizedCaseInsensitiveContains(searchText) == true ||
            order.orderReference?.localizedCaseInsensitiveContains(searchText) == true ||
            order.platform.rawValue.localizedCaseInsensitiveContains(searchText)
        }
        return searchFiltered.filter { OrderFilter.received.matchesOrder($0) }.count
    }
    
    private var completedOrdersCount: Int {
        let searchFiltered = searchText.isEmpty ? allOrders : allOrders.filter { order in
            order.customerName?.localizedCaseInsensitiveContains(searchText) == true ||
            order.orderReference?.localizedCaseInsensitiveContains(searchText) == true ||
            order.platform.rawValue.localizedCaseInsensitiveContains(searchText)
        }
        return searchFiltered.filter { OrderFilter.completed.matchesOrder($0) }.count
    }
    
    // Computed properties for order counts
    private var inProgressOrdersCount: Int {
        let searchFiltered = searchText.isEmpty ? allOrders : allOrders.filter { order in
            order.customerName?.localizedCaseInsensitiveContains(searchText) == true ||
            order.orderReference?.localizedCaseInsensitiveContains(searchText) == true ||
            order.platform.rawValue.localizedCaseInsensitiveContains(searchText)
        }
        return searchFiltered.filter { OrderFilter.inProgress.matchesOrder($0) }.count
    }
    
    
    
    // Helper function to get count text for tab
    private func countText(for filter: OrderFilter) -> String {
        switch filter {
        case .received:
            return "(\(receivedOrdersCount))"
        case .inProgress:
            return "(\(inProgressOrdersCount))"
        case .completed:
            return "(\(completedOrdersCount))"
        }
    }
    
    
    private var headerSection: some View {
        
        
        HStack(alignment: .center) {
            
            
            
            
            Text(String(localized: "Orders"))
                .font(.title)
                .padding(.horizontal,  15)
            
            Spacer()
            
            
            
            
            Button(action: {
                self.showingOrderCalendar = true
            }) {
                
                Image(systemName: "calendar.circle")
                    .font(.title)
                    .foregroundColor(.appTint)
                
            }
            .padding(.trailing, 8)
            
            
            
            
            
            Button(action: {
                showingAddOrder = true
            }) {
                
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(.appTint)
                
            }
            .padding(.trailing)
            
        }
        .frame(height: 50)
        
        
    }
    
    
    var body: some View {
        
        
        
        
        
        NavigationStack {
            
            VStack {
                headerSection
//
//                HeaderWithButton(
//                    title: String(localized: "Orders"),
//                    buttonContent: "plus.circle",
//                    isButtonImage: true,
//                    showTrailingButton: true,
//                    showLeadingButton: false,
//                    onButtonTap: {
//                   
//                        showingAddOrder = true
//                    }
//                )
//                
//                
//                
                
                
                

                
                
                SegmentedControl(
                    tabs: OrderFilter.allCases,
                    activeTab: $selectedFilter,
                    height: 35,
                    extraText: { filter in countText(for: filter) },
                    customText: { filter in filter.localizedTitle },
                    font: .callout,
                    activeTint: Color(UIColor.systemBackground),
                    inActiveTint: .gray.opacity(0.8)
                ) { size in
                    Capsule()
                        .fill(Color.appTint.gradient)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .background(
                    Capsule()
                        .fill(.thinMaterial)
                        .stroke(Color.appTint, lineWidth: 2)
                )
                .padding(.horizontal)
                
              
                
                
                
                
                
                
                
                
                
                
                
               
                
          
                if allOrders.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        String(localized: "No Orders"), 
                        systemImage: "bag", 
                        description: Text(String(localized: "Tap ")) + 
                                    Text(Image(systemName: "plus.circle")) + 
                                    Text(String(localized: " to add your first order."))
                    )
                    Spacer()
                } else if filteredOrders.isEmpty {
                    Spacer()
                    ContentUnavailableView(String(localized: "No Results"), systemImage: "magnifyingglass", description: Text(String(localized: "No orders match your search.")))
                    Spacer()
                } else {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            ForEach(groupedOrders, id: \.0) { dateString, ordersForDate in
                                Section(header: sectionHeader(dateString)) {
                                    ForEach(ordersForDate) { order in
                                        
                                        
                                        
                                        OrderCardView(height: 90, order: order)
                                            .swipeActions {
                                             
                                                
                                                Action(symbolImage: "trash.fill", tint: .white, background: Color.red) { resetPosition in
                                                    orderToDelete = order
                                                    confirmDelete = true
                                                }
                                            }
                                            .onTapGesture {
                                                selectedOrder = order
                                            }
                                        
                                        Color.clear.frame(height: 10)
                                    }
                                }
                            }
                        }
                        
                        Color.clear.frame(height: 40)
                    }
                  
                }
            }
            
            .alert( String(localized: "Confirm deletion"), isPresented: $confirmDelete, actions: {
                
                /// A destructive button that appears in red.
                Button(role: .destructive) {
                    if let order = orderToDelete {
                        deleteOrder(order)
                    }
                } label: {
                    Text(String(localized: "Delete"))
                }
                
                /// A cancellation button that appears with bold text.
                Button(String(localized: "Cancel"), role: .cancel) {
                    // Perform cancellation
                }
                
            }, message: {
                Text(String(localized: "This action cannot be undone"))
            })
            

            .fullScreenCover(isPresented: $showingAddOrder) {
                
                ZStack{
                    Color(.systemBackground)
                           .ignoresSafeArea()
                    OrderDetailView(mode: .add)
                }
            }
            .fullScreenCover(isPresented: $showingOrderCalendar) {
                OrderCalendarView()
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
        SectionHeader(title: dateString)
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding(10)
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


