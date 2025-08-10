//
//  SalesReportView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 08/08/2025.
//

import SwiftUI
import SwiftData
import PDFKit

struct SalesReportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allOrders: [Order]
    
    @State private var selectedPeriod: ReportPeriod = .all
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var customEndDate = Date()
    @State private var selectedMonth = Date()
    @State private var showingShareSheet = false
    @State private var reportPDF: Data?
    
    private var filteredOrders: [Order] {
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .all:
            return allOrders
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: selectedMonth)?.start ?? selectedMonth
            let endOfMonth = calendar.dateInterval(of: .month, for: selectedMonth)?.end ?? selectedMonth
            return allOrders.filter { $0.date >= startOfMonth && $0.date < endOfMonth }
        case .custom:
            let startOfDay = calendar.startOfDay(for: customStartDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: customEndDate)) ?? customEndDate
            return allOrders.filter { $0.date >= startOfDay && $0.date < endOfDay }
        }
    }
    
    private var reportData: SalesReportData {
        SalesReportData(orders: filteredOrders)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderWithButton(
                    title: "Sales Report",
                    buttonContent: "square.and.arrow.up",
                    isButtonImage: true,
                    showTrailingButton: true,
                    showLeadingButton: true,
                    onButtonTap: {
                        generateReportPDF()
                    }
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Period Selection
                        CustomCardView("Report Period") {
                            VStack(alignment: .leading, spacing: 15) {
                                Picker("Period", selection: $selectedPeriod) {
                                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                                        Text(period.displayName).tag(period)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                if selectedPeriod == .month {
                                    HStack {
                                        Text("Month:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Picker("Month", selection: Binding(
                                            get: { Calendar.current.component(.month, from: selectedMonth) },
                                            set: { newMonth in
                                                let year = Calendar.current.component(.year, from: selectedMonth)
                                                selectedMonth = Calendar.current.date(from: DateComponents(year: year, month: newMonth)) ?? selectedMonth
                                            }
                                        )) {
                                            ForEach(1...12, id: \.self) { month in
                                                Text(Calendar.current.monthSymbols[month - 1])
                                                    .tag(month)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        
                                        Picker("Year", selection: Binding(
                                            get: { Calendar.current.component(.year, from: selectedMonth) },
                                            set: { newYear in
                                                let month = Calendar.current.component(.month, from: selectedMonth)
                                                selectedMonth = Calendar.current.date(from: DateComponents(year: newYear, month: month)) ?? selectedMonth
                                            }
                                        )) {
                                            ForEach(2020...2030, id: \.self) { year in
                                                Text(String(year))
                                                    .tag(year)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    }
                                } else if selectedPeriod == .custom {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("From")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            DatePicker("", selection: $customStartDate, displayedComponents: [.date])
                                                .datePickerStyle(.compact)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("To")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            DatePicker("", selection: $customEndDate, displayedComponents: [.date])
                                                .datePickerStyle(.compact)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Summary Statistics
                        CustomCardView("Summary") {
                            VStack(spacing: 15) {
                                SalesMetricRow(title: "Total Orders", value: "\(reportData.totalOrders)")
                                SalesMetricRow(title: "Total Revenue", value: reportData.totalRevenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                                SalesMetricRow(title: "Total Costs", value: reportData.totalCosts.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                                SalesMetricRow(title: "Total Profit", value: reportData.totalProfit.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                                    .foregroundColor(reportData.totalProfit >= 0 ? .green : .red)
                                SalesMetricRow(title: "Average Order Value", value: reportData.averageOrderValue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                                SalesMetricRow(title: "Profit Margin", value: String(format: "%.1f%%", reportData.profitMargin))
                                    .foregroundColor(reportData.profitMargin >= 0 ? .green : .red)
                            }
                        }
                        
                        // Platform Breakdown
                        if !reportData.platformBreakdown.isEmpty {
                            CustomCardView("Sales by Platform") {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(Array(reportData.platformBreakdown.keys).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { platform in
                                        let data = reportData.platformBreakdown[platform]!
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Text(platform.rawValue)
                                                    .font(.headline)
                                                Spacer()
                                                Text("\(data.orderCount) orders")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            HStack {
                                                Text("Revenue: \(data.revenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))")
                                                    .font(.subheadline)
                                                Spacer()
                                                Text("Profit: \(data.profit.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))")
                                                    .font(.subheadline)
                                                    .foregroundColor(data.profit >= 0 ? .green : .red)
                                            }
                                        }
                                        .padding(.vertical, 5)
                                        
                                        if platform != Array(reportData.platformBreakdown.keys).sorted(by: { $0.rawValue < $1.rawValue }).last {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Status Breakdown
                        if !reportData.statusBreakdown.isEmpty {
                            CustomCardView("Orders by Status") {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(Array(reportData.statusBreakdown.keys.sorted { $0.rawValue < $1.rawValue }), id: \.self) { status in
                                        let count = reportData.statusBreakdown[status]!
                                        HStack {
                                            Circle()
                                                .fill(status.statusColor)
                                                .frame(width: 12, height: 12)
                                            Text(status.rawValue.capitalized)
                                                .font(.subheadline)
                                            Spacer()
                                            Text("\(count)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Top Customers
                        if !reportData.topCustomers.isEmpty {
                            CustomCardView("Top Customers") {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(reportData.topCustomers.prefix(5), id: \.customerName) { customer in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(customer.customerName)
                                                    .font(.subheadline)
                                                Text("\(customer.orderCount) orders")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text(customer.totalRevenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                                                .font(.subheadline)
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = reportPDF {
                    ActivityViewController(activityItems: [pdfData])
                }
            }
        }
    }
    
    private func generateReportPDF() {
        let pdfView = SalesReportPDFView(reportData: reportData, period: selectedPeriod)
        let renderer = ImageRenderer(content: pdfView)
        renderer.scale = 2.0
        
        if let renderedImage = renderer.uiImage {
            let pdfDocument = PDFDocument()
            let pdfPage = PDFPage(image: renderedImage)
            pdfDocument.insert(pdfPage!, at: 0)
            
            if let pdfData = pdfDocument.dataRepresentation() {
                self.reportPDF = pdfData
                showingShareSheet = true
            }
        }
    }
    
    private func generateReportText() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        var text = "SALES REPORT\n"
        text += "Generated: \(formatter.string(from: Date()))\n"
        text += "Period: \(selectedPeriod.displayName)\n\n"
        
        text += "SUMMARY:\n"
        text += "Total Orders: \(reportData.totalOrders)\n"
        text += "Total Revenue: \(reportData.totalRevenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))\n"
        text += "Total Costs: \(reportData.totalCosts.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))\n"
        text += "Total Profit: \(reportData.totalProfit.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))\n"
        text += "Average Order Value: \(reportData.averageOrderValue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))\n"
        text += "Profit Margin: " + String(format: "%.1f%%", reportData.profitMargin) + "\n\n"
        
        if !reportData.platformBreakdown.isEmpty {
            text += "PLATFORM BREAKDOWN:\n"
            for platform in reportData.platformBreakdown.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
                let data = reportData.platformBreakdown[platform]!
                text += "\(platform.rawValue): \(data.orderCount) orders, Revenue: \(data.revenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue))), Profit: \(data.profit.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))\n"
            }
            text += "\n"
        }
        
        if !reportData.statusBreakdown.isEmpty {
            text += "STATUS BREAKDOWN:\n"
            for status in reportData.statusBreakdown.keys.sorted { $0.rawValue < $1.rawValue } {
                let count = reportData.statusBreakdown[status]!
                text += "\(status.rawValue.capitalized): \(count) orders\n"
            }
            text += "\n"
        }
        
        if !reportData.topCustomers.isEmpty {
            text += "TOP CUSTOMERS:\n"
            for customer in reportData.topCustomers.prefix(5) {
                text += "\(customer.customerName): \(customer.orderCount) orders, \(customer.totalRevenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))\n"
            }
        }
    }
}

struct SalesMetricRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

enum ReportPeriod: CaseIterable {
    case all, month, custom
    
    var displayName: String {
        switch self {
        case .all: return "All Time"
        case .month: return "Month"
        case .custom: return "Custom"
        }
    }
}

struct SalesReportData {
    let orders: [Order]
    
    var totalOrders: Int {
        orders.count
    }
    
    var totalRevenue: Double {
        orders.reduce(0) { $0 + $1.itemsTotal }
    }
    
    var totalCosts: Double {
        orders.reduce(0) { $0 + $1.totalCost }
    }
    
    var totalProfit: Double {
        totalRevenue - totalCosts
    }
    
    var averageOrderValue: Double {
        totalOrders > 0 ? totalRevenue / Double(totalOrders) : 0
    }
    
    var profitMargin: Double {
        totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0
    }
    
    var platformBreakdown: [Platform: (orderCount: Int, revenue: Double, profit: Double)] {
        var breakdown: [Platform: (orderCount: Int, revenue: Double, profit: Double)] = [:]
        
        for order in orders {
            let current = breakdown[order.platform] ?? (0, 0.0, 0.0)
            breakdown[order.platform] = (
                current.orderCount + 1,
                current.revenue + order.itemsTotal,
                current.profit + order.profit
            )
        }
        
        return breakdown
    }
    
    var statusBreakdown: [OrderStatus: Int] {
        var breakdown: [OrderStatus: Int] = [:]
        
        for order in orders {
            breakdown[order.status, default: 0] += 1
        }
        
        return breakdown
    }
    
    var topCustomers: [(customerName: String, orderCount: Int, totalRevenue: Double)] {
        var customerData: [String: (orderCount: Int, totalRevenue: Double)] = [:]
        
        for order in orders {
            let customerName = order.customerName ?? "Unknown Customer"
            let current = customerData[customerName] ?? (0, 0.0)
            customerData[customerName] = (
                current.orderCount + 1,
                current.totalRevenue + order.itemsTotal
            )
        }
        
        return customerData.map { (customerName: $0.key, orderCount: $0.value.orderCount, totalRevenue: $0.value.totalRevenue) }
            .sorted { $0.totalRevenue > $1.totalRevenue }
    }
}

struct SalesReportPDFView: View {
    let reportData: SalesReportData
    let period: ReportPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("SALES REPORT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Generated: \(Date(), formatter: DateFormatter.mediumDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Period: \(period.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Summary Section
            VStack(alignment: .leading, spacing: 15) {
                Text("SUMMARY")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                    GridRow {
                        Text("Total Orders:")
                        Text("\(reportData.totalOrders)")
                            .fontWeight(.medium)
                    }
                    GridRow {
                        Text("Total Revenue:")
                        Text(reportData.totalRevenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                            .fontWeight(.medium)
                    }
                    GridRow {
                        Text("Total Costs:")
                        Text(reportData.totalCosts.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                            .fontWeight(.medium)
                    }
                    GridRow {
                        Text("Total Profit:")
                        Text(reportData.totalProfit.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                            .fontWeight(.medium)
                            .foregroundColor(reportData.totalProfit >= 0 ? .green : .red)
                    }
                    GridRow {
                        Text("Average Order Value:")
                        Text(reportData.averageOrderValue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                            .fontWeight(.medium)
                    }
                    GridRow {
                        Text("Profit Margin:")
                        Text(String(format: "%.1f%%", reportData.profitMargin))
                            .fontWeight(.medium)
                            .foregroundColor(reportData.profitMargin >= 0 ? .green : .red)
                    }
                }
            }
            
            if !reportData.platformBreakdown.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("PLATFORM BREAKDOWN")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(Array(reportData.platformBreakdown.keys).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { platform in
                        let data = reportData.platformBreakdown[platform]!
                        VStack(alignment: .leading, spacing: 4) {
                            Text(platform.rawValue)
                                .font(.headline)
                            HStack {
                                Text("Orders: \(data.orderCount)")
                                Spacer()
                                Text("Revenue: \(data.revenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))")
                                Spacer()
                                Text("Profit: \(data.profit.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))")
                                    .foregroundColor(data.profit >= 0 ? .green : .red)
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            if !reportData.statusBreakdown.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("ORDER STATUS BREAKDOWN")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Array(reportData.statusBreakdown.keys).sorted { $0.rawValue < $1.rawValue }, id: \.self) { status in
                            let count = reportData.statusBreakdown[status]!
                            HStack {
                                Text(status.rawValue.capitalized)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(count)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            }
            
            if !reportData.topCustomers.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("TOP CUSTOMERS")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(reportData.topCustomers.prefix(10), id: \.customerName) { customer in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(customer.customerName)
                                    .font(.subheadline)
                                Text("\(customer.orderCount) orders")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(customer.totalRevenue.formatted(.currency(code: LocaleManager.shared.currentCurrency.rawValue)))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(30)
        .frame(width: 595, height: 842) // A4 size in points
        .background(Color.white)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Set suggested filename for PDF
        if let pdfData = activityItems.first as? Data {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let filename = "Sales_Report_\(formatter.string(from: Date())).pdf"
            controller.setValue(filename, forKey: "subject")
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    SalesReportView()
        .modelContainer(for: Order.self, inMemory: true)
}
