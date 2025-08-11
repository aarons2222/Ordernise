//
//  DashboardView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData
import Charts

struct CategorySalesData: Identifiable, Equatable {
    let id = UUID()
    let category: String
    let revenue: Double
    let color: Color
    
    static func == (lhs: CategorySalesData, rhs: CategorySalesData) -> Bool {
        lhs.id == rhs.id &&
        lhs.category == rhs.category &&
        lhs.revenue == rhs.revenue
    }
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @StateObject private var localeManager = LocaleManager.shared

    @State private var selectedTimeFrame: TimeFrame = .thisMonth
    @State private var showingInfoSheet = false
    
    private var allOrders: [Order] {
        // Force reactivity to dummy mode changes
        _ = dummyDataManager.isDummyModeEnabled
        return dummyDataManager.getOrders(from: modelContext)
    }
    
    private var stockItems: [StockItem] {
        // Force reactivity to dummy mode changes
        _ = dummyDataManager.isDummyModeEnabled
        return dummyDataManager.getStockItems(from: modelContext)
    }
    
    enum TimeFrame: String, CaseIterable {
    //    case today = "Today"
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
//        case .today:
//            return allOrders.filter { calendar.isDate($0.date, inSameDayAs: now) }
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
        filteredOrders.filter { $0.status == .fulfilled || $0.status == .delivered }.count
    }
    
    private var totalRevenue: Double {
        filteredOrders
            .filter { $0.status == .fulfilled || $0.status == .delivered }
            .reduce(0) { total, order in
                total + order.revenue
            }
    }
    

    
    private var totalProfit: Double {
        filteredOrders
            .filter { $0.status == .fulfilled || $0.status == .delivered }
            .reduce(0) { total, order in
                total + order.profit
            }
    }
    
    private var totalInventoryValue: Double {
        stockItems.reduce(0) { total, item in
            total + (item.price * Double(item.quantityAvailable))
        }
    }
    
    private var lowStockItems: Int {
        stockItems.filter { $0.quantityAvailable <= 5 }.count
    }
    
    private var salesByCategory: [CategorySalesData] {
        let categoryRevenue = Dictionary(grouping: filteredOrders.filter { $0.status == .fulfilled || $0.status == .delivered }) { order in
            // Get category from the first order item (simplified approach)
            order.items.first?.stockItem?.category?.name ?? "Uncategorized"
        }.mapValues { orders in
            orders.reduce(0.0) { $0 + $1.revenue }
        }
        
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .red, 
            .pink, .cyan, .mint, .indigo, .teal
        ]
        
        return categoryRevenue.enumerated().map { index, item in
            CategorySalesData(
                category: item.key,
                revenue: item.value,
                color: colors[index % colors.count]
            )
        }
        .filter { $0.revenue > 0 }
        .sorted { $0.revenue > $1.revenue }
    }
    
    private func calculatePercentage(_ revenue: Double) -> Double {
        let total = salesByCategory.reduce(0) { $0 + $1.revenue }
        guard total > 0 else { return 0 }
        let percentage = (revenue / total) * 100
        return (percentage * 10).rounded() / 10
    }

    
    var body: some View {
        VStack(spacing: 0) {
            
            
            
            HeaderWithButton(
                title: "Dashboard",
                buttonContent: "info.circle",
                isButtonImage: true,
                showTrailingButton: true,
                showLeadingButton: false,
                onButtonTap: {
                    showingInfoSheet = true
                }
            )
            
            if !allOrders.isEmpty {
                timeFramePicker
                
            }
            
            
                VStack(spacing: 20) {
                    if filteredOrders.count < 6 {
             
                        
                        ContentUnavailableView("Not enough sales data", systemImage: "chart.pie", description: Text("As you add orders, you will be able to view sales metrics here"))


                        
                
                        
                    } else {
                        ScrollView {

                        metricsGrid
                        salesByCategoryChart
                        additionalMetrics
                            
                    }
                }
  
      
            }
            .padding(.top)

            Spacer()
            
      
        }
        .sheet(isPresented: $showingInfoSheet) {
            DashboardInfoSheet()
        }
        
    }
    

    
    // MARK: - UI Components
    
    private var salesByCategoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sales by Category")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                    .underline()
                Spacer()
                
                Image(systemName: "chart.pie")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .padding(.bottom, 20)
          
                Chart(salesByCategory) { data in
                    SectorMark(
                        angle: .value("Revenue", data.revenue),
                        innerRadius: 70,
                        angularInset: 1
                    )
                    .cornerRadius(5) 
                    .foregroundStyle(data.color)
                }
                .frame(height: 250)
                .animation(.easeInOut(duration: 0.1), value: salesByCategory)
            
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(salesByCategory.enumerated()), id: \.element.id) { index, data in
                    if !data.category.isEmpty {
                        HStack {
                            Image(systemName: "largecircle.fill.circle")
                                .font(.body)
                                .foregroundStyle(data.color)
                            
                            Text(data.category.capitalized)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(calculatePercentage(data.revenue), specifier: "%.1f")%")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }

    
    private var timeFramePicker: some View {
        SegmentedControl(
            tabs: TimeFrame.allCases,
            activeTab: $selectedTimeFrame,
            height: 45,
            font: .callout,
            activeTint: Color(UIColor.systemBackground),
            inActiveTint: .gray.opacity(0.8)
        ) { size in
            RoundedRectangle(cornerRadius: 22.5)
                .fill(Color.appTint.gradient)
                .padding(.horizontal, 4)
        }
        .padding(.horizontal)
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
                value: totalRevenue.formatted(localeManager.currencyFormatStyle),
                subtitle: "Total Income",
                icon: "dollarsign.circle.fill",
                color: .green
            )
            
            

            // Profit
            MetricCard(
                title: "Profit",
                value: totalProfit.formatted(localeManager.currencyFormatStyle),
                subtitle: "Net Profit",
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
                        
                        
                        Text("\(totalRevenue / Double(max(totalSales, 1)), format: localeManager.currencyFormatStyle)")

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
}

// MARK: - HeaderWithButton Component

struct HeaderWithButton: View {
    let title: String
    let buttonContent: String
    let isButtonImage: Bool
    let showTrailingButton: Bool
    let showLeadingButton: Bool
    let onButtonTap: (() -> Void)?
    
    
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        HStack(alignment: .center) {
            if showLeadingButton {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward.circle")
                        .font(.title)
                        .foregroundColor(.appTint)
                        .padding(.leading)
                }
            }
            
            Text(title)
                .font(.title)
                .padding(.horizontal, showLeadingButton ? 5 : 15)
            
            Spacer()
            
            
            
            
            
            
            if showTrailingButton {
                Button(action: {
                    onButtonTap?()
                }) {
                    if isButtonImage {
                        Image(systemName: buttonContent)
                            .font(.title)
                            .foregroundColor(.appTint)
                    } else {
                        Text(buttonContent)
                            .font(.title3)
                            .foregroundColor(.appTint)
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(height: 50)
    }
}

// MARK: - Dashboard Info Sheet Component

struct DashboardInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Sales Metrics Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Sales Metrics", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Total Sales", description: "Number of completed orders (fulfilled or delivered)")
                            InfoRow(title: "Revenue", description: "Total income from completed orders")
                            InfoRow(title: "Profit", description: "Revenue minus all costs (shipping, fees, product costs)")
                        }
                    }
                    
                    Divider()
                    
                    // Time Filters Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Time Filters", systemImage: "clock")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Today", description: "Orders placed today")
                            InfoRow(title: "This Week", description: "Orders from Monday onwards (week starts Monday)")
                            InfoRow(title: "This Month", description: "Orders from the beginning of this month")
                            InfoRow(title: "This Year", description: "Orders from January 1st")
                            InfoRow(title: "All Time", description: "All orders ever placed")
                        }
                    }
                    
                    Divider()
                    
                    // Inventory Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Inventory", systemImage: "shippingbox")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Total Value", description: "Current stock value (quantity × price)")
                            InfoRow(title: "Low Stock", description: "Items with 5 or fewer units remaining")
                        }
                    }
                    
                    Divider()
                    
                    // Important Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Important Notes", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Order Status", description: "Only completed orders (fulfilled or delivered status) count toward sales metrics")
                            InfoRow(title: "Revenue", description: "Revenue includes customer shipping charges")
                            InfoRow(title: "Profit", description: "Profit calculations include selling fees and costs")
                            InfoRow(title: "Time Filters", description: "Time filters show orders placed during that period")
                            InfoRow(title: "Week Definition", description: "Week starts Monday at 00:00:01, ends Sunday at 23:59:59")
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Dashboard Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appTint)
                }
            }
        }
    }
}

// Helper component for info rows
struct InfoRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}
