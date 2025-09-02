//
//  ExportDataView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 12/08/2025.
//

import SwiftUI
import SwiftData





enum ExportDataType: String, CaseIterable {
    case orders = "Orders"
    case stockItems = "Stock Items"
    case both = "Orders & Stock"
    
    // Localized display name for UI
    var localizedTitle: String {
        switch self {
        case .orders:
            return String(localized: "Orders")
        case .stockItems:
            return String(localized: "Stock Items")
        case .both:
            return String(localized: "Orders & Stock")
        }
    }
    
    var description: String {
        switch self {
        case .orders:
            return String(localized: "Order details, dates, revenue, profit, status")
        case .stockItems:
            return String(localized: "Item names, quantities, prices, categories")
        case .both:
            return String(localized: "Complete dataset with orders and inventory")
        }
    }
    
    var systemImage: String {
        switch self {
        case .orders: return "list.bullet.rectangle.portrait"
        case .stockItems: return "storefront"
        case .both: return "square.stack.3d.up"
        }
    }
}

enum ExportDateRange: String, CaseIterable {
    case last30Days = "Last 30 Days"
    case last3Months = "Last 3 Months"
    case last6Months = "Last 6 Months"
    case last12Months = "Last 12 Months"
    case allTime = "All Time"
    case customRange = "Custom Range"
    
    // Localized display name for UI
    var localizedTitle: String {
        switch self {
        case .last30Days:
            return String(localized: "Last 30 Days")
        case .last3Months:
            return String(localized: "Last 3 Months")
        case .last6Months:
            return String(localized: "Last 6 Months")
        case .last12Months:
            return String(localized: "Last 12 Months")
        case .allTime:
            return String(localized: "All Time")
        case .customRange:
            return String(localized: "Custom Range")
        }
    }
    
    func getDateRange() -> (start: Date?, end: Date?) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .last30Days:
            return (calendar.date(byAdding: .day, value: -30, to: now), now)
        case .last3Months:
            return (calendar.date(byAdding: .month, value: -3, to: now), now)
        case .last6Months:
            return (calendar.date(byAdding: .month, value: -6, to: now), now)
        case .last12Months:
            return (calendar.date(byAdding: .month, value: -12, to: now), now)
        case .allTime:
            return (nil, nil)
        case .customRange:
            return (nil, nil) // Will use custom dates
        }
    }
}

struct ExportDataView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @StateObject private var localeManager = LocaleManager.shared
    
    @State private var selectedDataType: ExportDataType = .orders
    @State private var selectedDateRange: ExportDateRange = .allTime
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    @State private var customEndDate = Date()
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?

    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var allOrders: [Order] {
        return dummyDataManager.getOrders(from: modelContext)
    }
    
    private var allStockItems: [StockItem] {
        return dummyDataManager.getStockItems(from: modelContext)
    }
    
    private var filteredOrders: [Order] {
        let dateRange = selectedDateRange.getDateRange()
        let startDate = selectedDateRange == .customRange ? customStartDate : dateRange.start
        let endDate = selectedDateRange == .customRange ? customEndDate : dateRange.end
        
        return allOrders.filter { order in
            if let start = startDate, order.orderReceivedDate < start { return false }
            if let end = endDate, order.orderReceivedDate > end { return false }
            return true
        }
    }
    
    var body: some View {
        let headerTitle = String(localized: "Export Data")
        
        return VStack(spacing: 0) {
            HeaderWithButton(
                title: headerTitle,
                buttonContent: "square.and.arrow.up",
                isButtonImage: true,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    exportData()
                }
            )
            
            ScrollView(showsIndicators: false) {
                
    VStack(alignment: .leading){
              
                    
                    
            SectionHeader(title: String(localized: "Choose what to export"))
                        .padding(.leading, 16)
                    
                    
                    
                    
                VStack(alignment: .leading, spacing: 20) {
                    // Data to Export section
                    CustomCardView(String(localized: "Data to Export")) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(ExportDataType.allCases, id: \.self) { dataType in
                                Button(action: {
                                    selectedDataType = dataType
                                }) {
                                    HStack {
                                        
                                        
                                        
                                        
                                        Image(systemName: dataType.systemImage)
                                            .foregroundColor(.appTint)
                                            .font(.title2)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(dataType.localizedTitle)
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(dataType.description)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        
                                        Image(systemName: selectedDataType == dataType ?  "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedDataType == dataType ? .appTint : .gray)
                                            .font(.title2)
                                        
                                    }
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Date Range section
                    // CustomCardView(String(localized: "Date Range")) {
                    VStack(alignment: .leading, spacing: 12) {
              
                        
                        DateRangePicker(selectedRange: $selectedDateRange)
                        if selectedDateRange == .customRange {
                            
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(String(localized: "From:"))
                                        .font(.callout)
                                        .foregroundColor(.text)
                                    Spacer()
                                    MyDatePicker(selectedDate: $customStartDate)
                                    
                                }
                                
                                Divider()
                                HStack {
                                    Text(String(localized: "To:"))
                                        .font(.callout)
                                        .foregroundColor(.text)
                                    Spacer()
                                    MyDatePicker(selectedDate: $customEndDate)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    
                    
                }
                    
                  
                    VStack(alignment: .leading){
                  
                        Color.clear.frame(height: 10)
                        
                        
                SectionHeader(title: String(localized: "Export Information"))
                            .padding(.leading, 16)
                        
                        
                        
                        
                    CustomCardView{
                        VStack(alignment: .leading, spacing: 12) {
                            if selectedDataType == .orders || selectedDataType == .both {
                                HStack {
                                    Image(systemName: "list.bullet.rectangle.portrait")
                                        .foregroundColor(.appTint)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text(String(localized: "ORDER DATA"))
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                        Text(filteredOrders.isEmpty ? String(localized: "No orders in selected range") : "\(filteredOrders.count) " + String(localized: "orders"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    Spacer()
                                }
                            }
                            
                            if selectedDataType == .stockItems || selectedDataType == .both {
                                HStack {
                                    Image(systemName: "storefront")
                                        .foregroundColor(.appTint)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text(String(localized: "STOCK ITEMS DATA"))
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                        Text(allStockItems.isEmpty ? String(localized: "No items") : "\(allStockItems.count) " + String(localized: "items"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    Spacer()
                                }
                            }
                            
                            HStack {
                                Image(systemName: "doc")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                                Text(String(localized: "Format: CSV"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    
                }
                    
                    // Export Button
                    Button(action: {
                        exportData()
                    }) {
                        HStack {
                            if isExporting {
                           
                            } else {
                             
                            }
                            Text(isExporting ? String(localized: "Exporting...") : String(localized: "Export Data"))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.clear)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background( Color.clear)
                        .cornerRadius(12)
                    }
                    .frame(height: 0)
                    .padding(.horizontal)
                    
                }
                .padding(.top)
                .padding(.horizontal, 20)
            }
            .toolbar(.hidden)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ActivityViewController(activityItems: [url])
            }
        }
        .alert(String(localized: "Export Status"), isPresented: $showingAlert) {
            Button(String(localized: "OK")) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func exportData() {
        print("🚀 Export started")
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let content: String
            let filename: String
            
            print("📊 Data type: \(self.selectedDataType)")
            print("📅 Date range: \(self.selectedDateRange)")
            print("📝 Filtered orders count: \(self.filteredOrders.count)")
            print("📦 All stock items count: \(self.allStockItems.count)")
            
            switch self.selectedDataType {
            case .orders:
                content = self.generateOrdersCSV()
                filename = "Orders_Export"
            case .stockItems:
                content = self.generateStockItemsCSV()
                filename = "Stock_Export"
            case .both:
                let ordersContent = self.generateOrdersCSV()
                let stockContent = self.generateStockItemsCSV()
                content = ordersContent + "\n\n" + stockContent
                filename = "Complete_Export"
            }
            
            print("📄 Generated content length: \(content.count)")
            
            // Add BOM for Excel compatibility
            let contentWithBOM = "\u{FEFF}" + content
            
            // Create file
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent("\(filename).csv")
            
            print("💾 Attempting to write to: \(fileURL.path)")
            
            do {
                try contentWithBOM.write(to: fileURL, atomically: true, encoding: .utf8)
                print("✅ File written successfully")
                
                DispatchQueue.main.async {
                    print("🎉 Setting exportedFileURL and showing share sheet")
                    print("🔗 File URL being set: \(fileURL.path)")
                    self.exportedFileURL = fileURL
                    print("🔗 exportedFileURL after setting: \(self.exportedFileURL?.path ?? "nil")")
                    self.isExporting = false
                    
                    self.showingShareSheet = true
                    print("🎭 About to show UIKit share sheet with URL: \(self.exportedFileURL?.path ?? "nil")")
                }
            } catch {
                print("❌ Export failed: \(error)")
                DispatchQueue.main.async {
                    self.alertMessage = String(localized: "Failed to create export file: \(error.localizedDescription)")
                    self.showingAlert = true
                    self.isExporting = false
                }
            }
        }
    }
    
    private func generateOrdersCSV() -> String {
        var csv = String(localized: "ORDERS DATA") + "\n"
        
        // Get order field preferences
        let orderPreferences = UserDefaults.standard.orderFieldPreferences
        let visibleFields = orderPreferences.allFieldsInOrder.filter { $0.isVisible }
        
        // Build header based on visible fields
        var headerColumns: [String] = []
        
        for fieldItem in visibleFields {
            if fieldItem.isBuiltIn, let builtInField = fieldItem.builtInField {
                headerColumns.append(builtInField.displayName)
            } else if let customField = fieldItem.customField {
                headerColumns.append(customField.name)
            }
        }
        
        // Add products column
        headerColumns.append(String(localized: "Products"))
        
        let header = headerColumns.joined(separator: ",")
        csv += header + "\n"
        
        // Generate rows
        for order in filteredOrders {
            var rowValues: [String] = []
            
            for fieldItem in visibleFields {
                if fieldItem.isBuiltIn, let builtInField = fieldItem.builtInField {
                    let value = getOrderBuiltInFieldValue(order: order, field: builtInField)
                    rowValues.append(value)
                } else if let customField = fieldItem.customField {
                    let value = order.attributes[customField.name] ?? ""
                    rowValues.append(value)
                }
            }
            
            // Add products information
            let products = order.items?.map { item in
                let itemName = item.stockItem?.name ?? String(localized: "Unknown Item")
                return "\(itemName) (x\(item.quantity))"
            }.joined(separator: "; ") ?? ""
            rowValues.append(products.isEmpty ? String(localized: "No items") : products)
            
            let row = rowValues.joined(separator: ",")
            csv += row + "\n"
        }
        
        return csv
    }
        
        private func getOrderBuiltInFieldValue(order: Order, field: BuiltInOrderField) -> String {
            switch field {
            case .orderDate:
                return order.orderReceivedDate.formatted(.dateTime.year().month().day())
            case .orderReference:
                return order.orderReference?.isEmpty == false ? order.orderReference! : String(localized: "N/A")
            case .customerName:
                return order.customerName?.isEmpty == false ? order.customerName! : String(localized: "N/A")
            case .orderStatus:
                return (order.status ?? .received).rawValue.capitalized
            case .platform:
                return (order.platform ?? .amazon).rawValue.capitalized
            case .shipping:
                return String(format: "%.2f", order.shippingCost)
            case .sellingFees:
                return String(format: "%.2f", order.sellingFees)
            case .additionalCosts:
                return String(format: "%.2f", order.additionalCosts)
            case .notes:
                return order.additionalCostNotes ?? ""
            case .itemsSection:
                return "\(order.items?.count ?? 0) " + String(localized: "items")
            case .orderCompletionDate:
                return order.orderCompletionDate?.formatted(.dateTime.year().month().day()) ?? String(localized: "N/A")
            }
        }

        private func generateStockItemsCSV() -> String {
            var csv = String(localized: "STOCK ITEMS DATA") + "\n"
            
            // Get stock field preferences
            let stockPreferences = UserDefaults.standard.stockFieldPreferences
            let visibleFields = stockPreferences.allFieldsInOrder.filter { $0.isVisible }
            
            // Build header based on visible fields
            var headerColumns: [String] = []
            
            for fieldItem in visibleFields {
                if fieldItem.isBuiltIn, let builtInField = fieldItem.builtInField {
                    headerColumns.append(builtInField.displayName)
                } else if let customField = fieldItem.customField {
                    headerColumns.append(customField.name)
                }
            }
            
            let header = headerColumns.joined(separator: ",")
            csv += header + "\n"
            
            // Generate rows
            for item in allStockItems {
                var rowValues: [String] = []
                
                for fieldItem in visibleFields {
                    if fieldItem.isBuiltIn, let builtInField = fieldItem.builtInField {
                        let value = getStockBuiltInFieldValue(item: item, field: builtInField)
                        rowValues.append(value)
                    } else if let customField = fieldItem.customField {
                        let value = item.attributes[customField.name] ?? ""
                        rowValues.append(value)
                    }
                }
                
                let row = rowValues.joined(separator: ",")
                csv += row + "\n"
            }
            
            return csv
        }
        
        private func getStockBuiltInFieldValue(item: StockItem, field: BuiltInStockField) -> String {
            switch field {
            case .name:
                return item.name.isEmpty ? String(localized: "N/A") : item.name
            case .quantityAvailable:
                return String(item.quantityAvailable)
            case .price:
                return String(format: "%.2f", item.price)
            case .cost:
                return String(format: "%.2f", item.cost)
            case .category:
                return item.category?.name ?? String(localized: "Uncategorized")
        }
    }
}

// MARK: - UIKit Activity View Controller for Sharing
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



#Preview {
    ExportDataView()
}



struct DateRangePicker: View {
    @Binding var selectedRange: ExportDateRange
    

    
    var body: some View {
        CustomDropdownMenu(
            title: "RANGE",
            options: ExportDateRange.allCases,
            selection: $selectedRange,
            optionToString: { $0.rawValue.capitalized }
        )
    }
}
