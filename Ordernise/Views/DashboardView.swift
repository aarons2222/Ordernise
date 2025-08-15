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

    @State private var selectedTimeFrame: TimeFrame = .thirtyDays
    @State private var showingInfoSheet = false
    
    private var allOrders: [Order] {
        return dummyDataManager.getOrders(from: modelContext)
    }
    
    private var stockItems: [StockItem] {
        return dummyDataManager.getStockItems(from: modelContext)
    }
    
    enum TimeFrame: String, CaseIterable {

        case thirtyDays = "30 Days"
        case sixMonths = "6 Months"
        case twelveMonths = "12 Months"
        
        var localizedTitle: String {
            switch self {
            case .thirtyDays:
                return String(localized: "30 Days")
            case .sixMonths:
                return String(localized: "6 Months")
            case .twelveMonths:
                return String(localized: "12 Months")
            }
        }
    }
    
    // Filtered orders based on selected time frame
    private var filteredOrders: [Order] {
        let now = Date()
        let calendar = Calendar.current
        
        let filtered: [Order]
        
        switch selectedTimeFrame {

        case .thirtyDays:
            // Last 30 days from now
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            filtered = allOrders.filter { $0.date >= thirtyDaysAgo && $0.date <= now }
        case .sixMonths:
            // Last 6 months from now
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            filtered = allOrders.filter { $0.date >= sixMonthsAgo && $0.date <= now }
        case .twelveMonths:
            // Last 12 months from now
            let twelveMonthsAgo = calendar.date(byAdding: .month, value: -12, to: now) ?? now
            filtered = allOrders.filter { $0.date >= twelveMonthsAgo && $0.date <= now }
        }
        
        // Sort by date descending (most recent first)
        return filtered.sorted { $0.date > $1.date }
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
            // Get category object from the first order item
            order.items.first?.stockItem?.category
        }.compactMapValues { orders in
            orders.isEmpty ? nil : orders.reduce(0.0) { $0 + $1.revenue }
        }
        
        // Fallback colors for uncategorized items
//        let fallbackColors: [Color] = [
//            .blue, .green, .orange, .purple, .red, 
//            .pink, .cyan, .mint, .indigo, .teal
//        ]
//        
        var result: [CategorySalesData] = []
        var uncategorizedRevenue: Double = 0
      //  var fallbackColorIndex = 0
        
        for (category, revenue) in categoryRevenue {
            if let category = category {
                // Use the actual category color
                result.append(CategorySalesData(
                    category: category.name,
                    revenue: revenue,
                    color: category.color
                ))
            } else {
                // Accumulate uncategorized revenue
                uncategorizedRevenue += revenue
            }
        }
        
        // Add uncategorized items if any
        if uncategorizedRevenue > 0 {
            result.append(CategorySalesData(
                category: String(localized: "Uncategorized"),
                revenue: uncategorizedRevenue,
                color: .gray
            ))
        }
        
        return result
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
                title: String(localized: "Dashboard"),
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
             
                        
                        ContentUnavailableView(String(localized: "Not enough sales data"), systemImage: "chart.pie", description: Text(String(localized: "As you add orders, you will be able to view sales metrics here")))


                        
                
                        
                    } else {
                        ScrollView {

                        metricsGrid
                        salesByCategoryChart
                        additionalMetrics
                            
                            Color.clear.frame(height: 40)
                            
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
        
        CustomCardView{
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(String(localized: "Sales by Category"))
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(.primary)
                        .underline()
                    Spacer()
                    
                
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
        }
        .padding()
       
      
    }

    
    private var timeFramePicker: some View {
        SegmentedControl(
            tabs: TimeFrame.allCases,
            activeTab: $selectedTimeFrame,
            height: 35,
            customText: { timeFrame in timeFrame.localizedTitle },
            font: .callout,
            activeTint: Color(UIColor.systemBackground),
            inActiveTint: .gray.opacity(0.8)
        ) { size in
            RoundedRectangle(cornerRadius: 22.5)
                .fill(Color.appTint.gradient)
             
        }
        .background(
            Capsule()
                .stroke(Color.appTint, lineWidth: 3)
        )
        .padding(.horizontal)
    }
    
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Sales Count
            MetricCard(
                title: String(localized: "Sales"),
                value: "\(totalSales)",
                subtitle: String(localized: "Completed Orders"),
                icon: "cart",
                color: .blue
            )
            
            // Revenue
            MetricCard(
                title: String(localized: "Revenue"),
                value: totalRevenue.formatted(localeManager.currencyFormatStyle),
                subtitle: String(localized: "Total Income"),
                icon: "\(localeManager.currencySymbolName)",
                color: .green
            )
            
            

            // Profit
            MetricCard(
                title: String(localized: "Profit"),
                value: totalProfit.formatted(localeManager.currencyFormatStyle),
                subtitle: String(localized: "Net Profit"),
                icon: "chart.line.uptrend.xyaxis",
                color: totalProfit >= 0 ? .green : .red
            )
            
            // Profit Margin
            MetricCard(
                title: String(localized: "Margin"),
                value: totalRevenue > 0 ? "\(Int((totalProfit / totalRevenue) * 100))%" : "0%",
                subtitle: String(localized: "Profit Margin"),
                icon: "percent",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    

    
    private var additionalMetrics: some View {
        
        
        
        // Quick Stats
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Quick Stats"))
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                HStack {
                    Text(String(localized: "Total Orders (\(selectedTimeFrame.localizedTitle))"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(filteredOrders.count)")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text(String(localized: "Pending Orders"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(filteredOrders.filter { $0.status == .pending }.count)")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text(String(localized: "Total Stock Items"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(stockItems.count)")
                        .fontWeight(.medium)
                }
                
                if totalRevenue > 0 {
                    Divider()
                    HStack {
                        Text(String(localized: "Average Order Value"))
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
            CustomCardView{
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
           
                
            }
        }
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
                        Label(String(localized: "Sales Metrics"), systemImage: "chart.line.uptrend.xyaxis")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: String(localized: "Total Sales"), description: String(localized: "Number of completed orders (fulfilled or delivered)"))
                            InfoRow(title: String(localized: "Revenue"), description: String(localized: "Total income from completed orders"))
                            InfoRow(title: String(localized: "Profit"), description: String(localized: "Revenue minus all costs (shipping, fees, product costs)"))
                        }
                    }
                    
                    Divider()
                    
                    // Time Filters Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label(String(localized: "Time Filters"), systemImage: "clock")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: String(localized: "30 Days"), description: String(localized: "Orders from the last 30 days up to now"))
                            InfoRow(title: String(localized: "6 Months"), description: String(localized: "Orders from the last 6 months up to now"))
                            InfoRow(title: String(localized: "12 Months"), description: String(localized: "Orders from the last 12 months up to now"))
                        }
                    }
                    
                    Divider()
                    
                    // Inventory Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label(String(localized: "Inventory"), systemImage: "shippingbox")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: String(localized: "Total Value"), description: String(localized: "Current stock value (quantity × price)"))
                            InfoRow(title: String(localized: "Low Stock"), description: String(localized: "Items with 5 or fewer units remaining"))
                        }
                    }
                    
                    Divider()
                    
                    // Important Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label(String(localized: "Important Notes"), systemImage: "info.circle")
                            .font(.headline)
                            .foregroundColor(.appTint)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: String(localized: "Order Status"), description: String(localized: "Only completed orders (fulfilled or delivered status) count toward sales metrics"))
                            InfoRow(title: String(localized: "Revenue"), description: String(localized: "Revenue includes customer shipping charges"))
                            InfoRow(title: String(localized: "Profit"), description: String(localized: "Profit calculations include selling fees and costs"))
                            InfoRow(title: String(localized: "Time Filters"), description: String(localized: "All time periods are rolling windows from the current date and time backwards"))
                            InfoRow(title: String(localized: "Rolling Periods"), description: String(localized: "30 Days = last 30 days, etc. Updated in real-time"))
                            InfoRow(title: String(localized: "Data Sorting"), description: String(localized: "Orders are sorted by date with most recent first within each time period"))
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle(String(localized: "Dashboard Information"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
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
