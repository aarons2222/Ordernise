//
//  DashboardView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allOrders: [Order]
    @Query private var stockItems: [StockItem]
    

    @State private var selectedTimeFrame: TimeFrame = .thisMonth
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case thisYear = "This Year"
        case allTime = "All Time"
    }
    
    // Filtered orders based on selected time frame
    private var filteredOrders: [Order] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeFrame {
        case .today:
            return allOrders.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .thisWeek:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return allOrders.filter { $0.date >= weekStart }
        case .thisMonth:
            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return allOrders.filter { $0.date >= monthStart }
        case .thisYear:
            let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return allOrders.filter { $0.date >= yearStart }
        case .allTime:
            return allOrders
        }
    }
    
    // Calculate metrics
    private var totalSales: Int {
        filteredOrders.filter { $0.status == .fulfilled }.count
    }
    
    private var totalRevenue: Double {
        filteredOrders
            .filter { $0.status == .fulfilled }
            .reduce(0) { total, order in
                total + order.items.reduce(0) { itemTotal, item in
                    itemTotal + (item.stockItem?.price ?? 0) * Double(item.quantity)
                }
            }
    }
    
    private var totalCost: Double {
        filteredOrders
            .filter { $0.status == .fulfilled }
            .reduce(0) { total, order in
                total + order.items.reduce(0) { itemTotal, item in
                    itemTotal + (item.stockItem?.cost ?? 0) * Double(item.quantity)
                }
            }
    }
    
    private var totalProfit: Double {
        totalRevenue - totalCost
    }
    
    private var totalInventoryValue: Double {
        stockItems.reduce(0) { total, item in
            total + (item.price * Double(item.quantityAvailable))
        }
    }
    
    private var lowStockItems: Int {
        stockItems.filter { $0.quantityAvailable <= 5 }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderWithButton(
                title: "Dashboard",
                buttonImage: "line.3.horizontal.decrease.circle",
                showTrailingButton: false,
                showLeadingButton: false
            ) {
          
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    if allOrders.isEmpty {
                        // Show placeholder when no orders exist
                        emptyStatePlaceholder
                    } else {
                        // Time Frame Picker
                        timeFramePicker
                        
                        // Key Metrics Grid
                        metricsGrid
                        
                        // Additional Insights
                        additionalMetrics
                    }
                }
                .padding()
            }
        }
       
    }
    
    // MARK: - UI Components
    
    private var emptyStatePlaceholder: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            // Title and message
            VStack(spacing: 8) {
                Text("No Orders Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first order to see business analytics and insights here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Quick stats for inventory
            if !stockItems.isEmpty {
                VStack(spacing: 16) {
                    Divider()
                        .padding(.horizontal, 32)
                    
                    Text("Current Inventory")
                        .font(.headline)
                    
                    HStack(spacing: 32) {
                        VStack {
                            Text("\(stockItems.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text(totalInventoryValue.formatted(.currency(code: "GBP")))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Value")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if lowStockItems > 0 {
                            VStack {
                                Text("\(lowStockItems)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("Low Stock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var timeFramePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time Period")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Button(action: {
                            selectedTimeFrame = timeFrame
                        }) {
                            Text(timeFrame.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedTimeFrame == timeFrame ? .semibold : .regular)
                                .foregroundColor(selectedTimeFrame == timeFrame ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedTimeFrame == timeFrame ? Color.blue : Color(.systemGray6))
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Sales Count
            MetricCard(
                title: "Sales",
                value: "\(totalSales)",
                subtitle: "Completed Orders",
                icon: "cart.fill",
                color: .blue
            )
            
            // Revenue
            MetricCard(
                title: "Revenue",
                value: totalRevenue.formatted(.currency(code: "GBP")),
                subtitle: "Total Income",
                icon: "dollarsign.circle.fill",
                color: .green
            )
            
            // Profit
            MetricCard(
                title: "Profit",
                value: totalProfit.formatted(.currency(code: "GBP")),
                subtitle: "Net Earnings",
                icon: "chart.line.uptrend.xyaxis",
                color: totalProfit >= 0 ? .green : .red
            )
            
            // Profit Margin
            MetricCard(
                title: "Margin",
                value: totalRevenue > 0 ? "\(Int((totalProfit / totalRevenue) * 100))%" : "0%",
                subtitle: "Profit Margin",
                icon: "percent",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    
    private var additionalMetrics: some View {
        VStack(spacing: 16) {
            // Inventory Overview
            VStack(alignment: .leading, spacing: 12) {
                Text("Inventory Overview")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    // Total Inventory Value
                    HStack {
                        Image(systemName: "cube.box.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(totalInventoryValue.formatted(.currency(code: "GBP")))
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Inventory Value")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Low Stock Alert
                    HStack {
                        Image(systemName: lowStockItems > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundColor(lowStockItems > 0 ? .orange : .green)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("\(lowStockItems)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Low Stock Items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            // Quick Stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Stats")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Orders (\(selectedTimeFrame.rawValue))")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(filteredOrders.count)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Pending Orders")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(filteredOrders.filter { $0.status == .pending }.count)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Total Stock Items")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(stockItems.count)")
                            .fontWeight(.medium)
                    }
                    
                    if totalRevenue > 0 {
                        Divider()
                        HStack {
                            Text("Average Order Value")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text((totalRevenue / Double(max(totalSales, 1))).formatted(.currency(code: "GBP")))
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Metric Card Component

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
}




import SwiftUI

struct HeaderWithButton: View {
    let title: String
    let buttonImage: String
    let showTrailingButton: Bool
    let showLeadingButton: Bool
    let onButtonTap: (() -> Void)? // make optional to handle custom taps or default behavior
    
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        HStack(alignment: .center) {
            if showLeadingButton {
                Button(action: {
                   
                        presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Image(systemName: "chevron.backward.circle")
                        .font(.title)
                        .foregroundStyle(.color1)
                        .padding(.leading)
                }
            }

            Text(title)
                .font(.title)
                .padding(.horizontal, showLeadingButton ? 5 : 15)

            Spacer()

            if showTrailingButton {
                Button(action: {
                    if let onButtonTap = onButtonTap {
                        onButtonTap()
                    } 
                }) {
                    Image(systemName: buttonImage)
                        .font(.title)
                        .foregroundStyle(.color1)
                        .padding(.horizontal)
                }
            }
        }
        .frame(height: 50)
    }
}
