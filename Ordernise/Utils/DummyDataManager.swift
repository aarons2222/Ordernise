//
//  DummyDataManager.swift
//  Ordernise
//
//  Created by Aaron Strickland on 11/08/2025.
//

import Foundation
import SwiftData
internal import Combine

class DummyDataManager: ObservableObject {
    static let shared = DummyDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let dummyModeKey = "isDummyModeEnabled"
    
    @Published var isDummyModeEnabled: Bool {
        didSet {
            userDefaults.set(isDummyModeEnabled, forKey: dummyModeKey)
            
            // Always clear cached dummy data when toggling mode (both on and off)
            // This ensures fresh data generation with updated logic
            _dummyOrders = nil
            _dummyStockItems = nil
            _dummyCategories = nil
        }
    }
    
    private var _dummyOrders: [Order]?
    private var _dummyStockItems: [StockItem]?
    private var _dummyCategories: [Category]?
    
    private init() {
        isDummyModeEnabled = userDefaults.bool(forKey: dummyModeKey)
    }
    
    // MARK: - Dummy Orders
    
    func getDummyOrders() -> [Order] {
        if _dummyOrders == nil {
            _dummyOrders = DummyDataGenerator.shared.generateDummyOrders()
            
            // Debug: Print order dates and statuses for troubleshooting
            let calendar = Calendar.current
            let now = Date()
            
            let todayOrders = _dummyOrders?.filter { calendar.isDate($0.orderReceivedDate, inSameDayAs: now) } ?? []
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let weekOrders = _dummyOrders?.filter { $0.orderReceivedDate >= weekStart } ?? []
            
            print("DEBUG: Generated \(todayOrders.count) orders for TODAY")
            print("DEBUG: Generated \(weekOrders.count) orders for THIS WEEK")
            
            for order in todayOrders.prefix(3) {
                print("DEBUG: Today order - Date: \(order.orderReceivedDate), Status: \(order.status), Revenue: \(order.revenue)")
            }
        }
        return _dummyOrders ?? []
    }
    
    func getDummyStockItems() -> [StockItem] {
        if _dummyStockItems == nil {
            // Extract stock items from dummy orders to maintain consistency
            let orders = getDummyOrders()
            var stockItemsDict: [UUID: StockItem] = [:]
            
            for order in orders {
                for orderItem in order.items {
                    if let stockItem = orderItem.stockItem {
                        stockItemsDict[stockItem.id] = stockItem
                    }
                }
            }
            _dummyStockItems = Array(stockItemsDict.values)
        }
        return _dummyStockItems ?? []
    }
    
    func getDummyCategories() -> [Category] {
        if _dummyCategories == nil {
            _dummyCategories = DummyDataGenerator.shared.generateDummyCategories()
        }
        return _dummyCategories ?? []
    }
    
    // MARK: - Data Access Methods
    
    /// Returns either dummy orders or real orders based on current mode
    func getOrders(from context: ModelContext?) -> [Order] {
        if isDummyModeEnabled {
            return getDummyOrders()
        } else {
            guard let context = context else { return [] }
            let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.orderReceivedDate, order: .reverse)])
            return (try? context.fetch(descriptor)) ?? []
        }
    }
    
    /// Returns either dummy stock items or real stock items based on current mode
    func getStockItems(from context: ModelContext?) -> [StockItem] {
        if isDummyModeEnabled {
            return getDummyStockItems()
        } else {
            guard let context = context else { return [] }
            let descriptor = FetchDescriptor<StockItem>(sortBy: [SortDescriptor(\.name)])
            return (try? context.fetch(descriptor)) ?? []
        }
    }
    
    /// Returns either dummy categories or real categories based on current mode
    func getCategories(from context: ModelContext?) -> [Category] {
        if isDummyModeEnabled {
            return getDummyCategories()
        } else {
            guard let context = context else { return [] }
            let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
            return (try? context.fetch(descriptor)) ?? []
        }
    }
    
    /// Filters orders by search text (works for both dummy and real data)
    func searchOrders(_ orders: [Order], searchText: String) -> [Order] {
        guard !searchText.isEmpty else { return orders }
        
        return orders.filter { order in
            // Search in customer name, order reference, platform
            let searchableText = [
                order.customerName,
                order.orderReference,
                order.platform.rawValue,
                order.status.rawValue
            ].compactMap { $0 }.joined(separator: " ").lowercased()
            
            return searchableText.contains(searchText.lowercased())
        }
    }
    
    /// Filters stock items by search text (works for both dummy and real data)
    func searchStockItems(_ stockItems: [StockItem], searchText: String) -> [StockItem] {
        guard !searchText.isEmpty else { return stockItems }
        
        return stockItems.filter { stockItem in
            // Search in item name and attributes
            var searchableText = stockItem.name.lowercased()
            
            // Add attribute values to searchable text
            for (_, value) in stockItem.attributes {
                searchableText += " " + value.lowercased()
            }
            
            return searchableText.contains(searchText.lowercased())
        }
    }
    
    // MARK: - Analytics Helper Methods
    
    /// Get sales data for analytics (supports both dummy and real data)
    func getSalesAnalytics(from context: ModelContext?) -> (totalRevenue: Double, totalProfit: Double, totalOrders: Int) {
        let orders = getOrders(from: context)
        
        let totalRevenue = orders.reduce(0) { $0 + $1.revenue }
        let totalProfit = orders.reduce(0) { $0 + $1.profit }
        let totalOrders = orders.count
        
        return (totalRevenue, totalProfit, totalOrders)
    }
    
    /// Get monthly sales data for charts
    func getMonthlySalesData(from context: ModelContext?) -> [(month: String, revenue: Double, profit: Double)] {
        let orders = getOrders(from: context)
      //  let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        var monthlyData: [String: (revenue: Double, profit: Double)] = [:]
        
        for order in orders {
            let monthKey = formatter.string(from: order.orderReceivedDate)
            if monthlyData[monthKey] == nil {
                monthlyData[monthKey] = (0, 0)
            }
            monthlyData[monthKey]!.revenue += order.revenue
            monthlyData[monthKey]!.profit += order.profit
        }
        
        return monthlyData.map { (month: $0.key, revenue: $0.value.revenue, profit: $0.value.profit) }
            .sorted { formatter.date(from: $0.month) ?? Date.distantPast < formatter.date(from: $1.month) ?? Date.distantPast }
    }
    
    // MARK: - Utility Methods
    
    /// Clear all cached dummy data (useful for refreshing data)
    func clearDummyDataCache() {
        _dummyOrders = nil
        _dummyStockItems = nil
        _dummyCategories = nil
    }
    
    /// Reset dummy mode to disabled
    func resetDummyMode() {
        isDummyModeEnabled = false
        clearDummyDataCache()
    }
    
    /// Force refresh of dummy data (useful for debugging)
    func forceRefresh() {
        clearDummyDataCache()
        // Force regeneration
        _ = getDummyOrders()
    }
}

// MARK: - Extensions for easier integration

extension DummyDataManager {
    /// Convenience method for OrderList to get filtered orders
    func getFilteredOrders(from context: ModelContext?, searchText: String) -> [Order] {
        let orders = getOrders(from: context)
        return searchOrders(orders, searchText: searchText)
    }
    
    /// Convenience method for StockList to get filtered stock items
    func getFilteredStockItems(from context: ModelContext?, searchText: String) -> [StockItem] {
        let stockItems = getStockItems(from: context)
        return searchStockItems(stockItems, searchText: searchText)
    }
}
