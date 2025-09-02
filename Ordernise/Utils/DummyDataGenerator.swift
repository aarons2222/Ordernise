//
//  DummyDataGenerator.swift
//  Ordernise
//
//  Created by Aaron Strickland on 11/08/2025.
//

import Foundation
import SwiftData

struct HardcodedOrderData {
    let daysAgo: Int
    let hourOffset: Int
    let reference: String
    let customerName: String
    let status: OrderStatus
    let platform: Platform
    let shippingCost: Double
    let sellingFees: Double
    let additionalCosts: Double
    let shippingMethod: String
    let trackingReference: String?
    let customerShippingCharge: Double
    let deliveryMethod: DeliveryMethod
    let revenue: Double
    let profit: Double
    let productKeyword: String
    let quantity: Int
}

class DummyDataGenerator {
    static let shared = DummyDataGenerator()
    private init() {}
    
    // Sample product names for realistic dummy data
    private let productNames = [
        "Vintage Nike Air Jordan 1", "Apple iPhone 13 Case", "Adidas Ultraboost Sneakers",
        "Samsung Galaxy Watch", "Sony WH-1000XM4 Headphones", "MacBook Pro Sleeve",
        "Champion Hoodie", "Levi's 501 Jeans", "Ray-Ban Sunglasses", "Fossil Watch",
        "North Face Jacket", "Converse Chuck Taylor", "Under Armour T-Shirt", 
        "Patagonia Backpack", "Yeezy Boost 350", "AirPods Pro Case", "Nike Dunk Low",
        "Vans Old Skool", "Supreme Box Logo Tee", "Carhartt Work Jacket",
        "Timberland Boots", "New Balance 574", "Jordan 4 Retro", "Off-White Hoodie",
        "Balenciaga Triple S", "Gucci Belt", "Louis Vuitton Wallet", "Chanel Bag",
        "Rolex Submariner", "Omega Speedmaster", "Vintage Vinyl Record",
        "Gaming Mouse", "Mechanical Keyboard", "iPhone Charger", "Wireless Earbuds",
        "Smartphone Grip", "Laptop Stand", "USB-C Hub", "Power Bank", "Bluetooth Speaker",
        "Fitness Tracker", "Running Shoes", "Yoga Mat", "Protein Shaker", "Gym Bag",
        "Baseball Cap", "Beanie Hat", "Leather Wallet", "Crossbody Bag", "Tote Bag"
    ]
    
    private let customerNames = [
        "John Smith", "Emma Johnson", "Michael Brown", "Sarah Davis", "David Wilson",
        "Lisa Anderson", "James Miller", "Jennifer Taylor", "Robert Thomas", "Mary Jackson",
        "Christopher White", "Patricia Harris", "Matthew Martin", "Linda Thompson", "Daniel Garcia",
        "Barbara Martinez", "Paul Robinson", "Susan Clark", "Mark Rodriguez", "Nancy Lewis",
        "Donald Lee", "Karen Walker", "Steven Hall", "Betty Allen", "Edward Young",
        "Helen Hernandez", "Ryan King", "Donna Wright", "Jason Lopez", "Carol Hill",
        "Kevin Scott", "Ruth Green", "Brian Adams", "Sharon Baker", "George Gonzalez",
        "Sandra Nelson", "Anthony Carter", "Lisa Mitchell", "Kenneth Perez", "Michelle Roberts",
        "Joshua Turner", "Kimberly Phillips", "Andrew Campbell", "Angela Parker", "Timothy Evans",
        "Brenda Edwards", "Daniel Collins", "Amy Stewart", "Thomas Sanchez", "Anna Morris"
    ]
    
    private let shippingMethods = [
        "Royal Mail 1st Class", "Royal Mail 2nd Class", "DPD Next Day", "Hermes Standard",
        "UPS Express", "DHL Express", "Amazon Prime", "Collected in Person", "Evri 48hr"
    ]
    
    private let categoryData: [(name: String, color: String)] = [
        ("Electronics", "#007AFF"),
        ("Clothing", "#FF3B30"),
        ("Footwear", "#FF9500"),
        ("Accessories", "#FFCC02"),
        ("Vintage", "#32D74B"),
        ("Gaming", "#5856D6"),
        ("Books", "#AF52DE"),
        ("Sports", "#FF2D92"),
        ("Beauty", "#A2845E"),
        ("Home & Garden", "#8E8E93")
    ]
    
    func generateDummyOrders() -> [Order] {
        return generateHardcodedOrders()
    }
    
    private func generateHardcodedOrders() -> [Order] {
        let calendar = Calendar.current
        let now = Date()
        let stockItems = generateDummyStockItems()
        
        // Hardcoded order data for consistency
        let hardcodedOrderData = getHardcodedOrderData()
        
        var orders: [Order] = []
        
        for (_, orderData) in hardcodedOrderData.enumerated() {
            let orderDate = calendar.date(byAdding: .day, value: -orderData.daysAgo, to: now) ?? now
            let finalDate = calendar.date(byAdding: .hour, value: orderData.hourOffset, to: orderDate) ?? orderDate
         
            let order = Order(
                orderReceivedDate: finalDate,
                orderReference: orderData.reference,
                customerName: orderData.customerName,
                status: orderData.status,
                platform: orderData.platform,
                shippingCost: orderData.shippingCost,
                sellingFees: orderData.sellingFees,
                customerShippingCharge: orderData.customerShippingCharge,
                deliveryMethod: orderData.deliveryMethod,
                revenue: orderData.revenue,
                profit: orderData.profit
            )
            
            // Add order items based on the hardcoded data
            var matchedStockItem: StockItem?
            
            // Try to find matching stock item by keyword (case-insensitive)
            matchedStockItem = stockItems.first { stockItem in
                stockItem.name.lowercased().contains(orderData.productKeyword.lowercased())
            }
            
            // If no match found, try alternative matching
            if matchedStockItem == nil {
                matchedStockItem = findAlternativeStockItem(for: orderData.productKeyword, in: stockItems)
            }
            
            // If still no match, use a random stock item to ensure every order has products
            if matchedStockItem == nil {
                matchedStockItem = stockItems.randomElement()
            }
            
            // Add the order item
            if let stockItem = matchedStockItem {
                let orderItem = OrderItem(
                    quantity: orderData.quantity,
                    stockItem: stockItem
                )
                if order.items == nil {
                    order.items = []
                }
                order.items?.append(orderItem)
            }
            
            orders.append(order)
        }
        
        print("DEBUG: Generated \(orders.count) hardcoded dummy orders")
        
        // Debug output
        let completedOrders = orders.filter { $0.status == .fulfilled }
        let incompleteOrders = orders.filter { $0.status != .fulfilled }
        
        print("DEBUG: COMPLETED ORDERS: \(completedOrders.count), Total Revenue: £\(completedOrders.reduce(0) { $0 + $1.revenue })")
        print("DEBUG: INCOMPLETE ORDERS: \(incompleteOrders.count)")
        
        let statusCounts = Dictionary(grouping: incompleteOrders, by: { $0.status ?? .received })
        for (status, statusOrders) in statusCounts {
            print("DEBUG: \(status.rawValue.uppercased()): \(statusOrders.count) orders")
        }
        
        return orders
    }
    
    private func getHardcodedOrderData() -> [HardcodedOrderData] {
        return [
            // Today's Orders (3 completed, 2 incomplete)
            HardcodedOrderData(daysAgo: 0, hourOffset: 2, reference: "ORD-001", customerName: "Sarah Johnson", status: .fulfilled, platform: .amazon, shippingCost: 4.99, sellingFees: 12.50, additionalCosts: 0.0, shippingMethod: "Royal Mail 1st Class", trackingReference: "RG123456789GB", customerShippingCharge: 6.99, deliveryMethod: .shipped, revenue: 89.99, profit: 72.50, productKeyword: "iPhone", quantity: 1),
            HardcodedOrderData(daysAgo: 0, hourOffset: 5, reference: "ORD-002", customerName: "Michael Chen", status: .fulfilled, platform: .ebay, shippingCost: 3.50, sellingFees: 8.75, additionalCosts: 0.0, shippingMethod: "DPD Next Day", trackingReference: "DPD987654321", customerShippingCharge: 4.99, deliveryMethod: .shipped, revenue: 124.99, profit: 112.74, productKeyword: "Jordan", quantity: 1),
            HardcodedOrderData(daysAgo: 0, hourOffset: 8, reference: "ORD-003", customerName: "Emma Williams", status: .fulfilled, platform: .etsy, shippingCost: 2.99, sellingFees: 5.25, additionalCosts: 0.0, shippingMethod: "Standard Post", trackingReference: nil, customerShippingCharge: 3.50, deliveryMethod: .shipped, revenue: 67.50, profit: 59.26, productKeyword: "Necklace", quantity: 2),
            HardcodedOrderData(daysAgo: 0, hourOffset: 12, reference: "ORD-004", customerName: "James Brown", status: .processing, platform: .amazon, shippingCost: 0.0, sellingFees: 0.0, additionalCosts: 0.0, shippingMethod: "", trackingReference: nil, customerShippingCharge: 0.0, deliveryMethod: .collected, revenue: 0.0, profit: 0.0, productKeyword: "MacBook", quantity: 1),
            HardcodedOrderData(daysAgo: 0, hourOffset: 15, reference: "ORD-005", customerName: "Lucy Davis", status: .pending, platform: .marketplace, shippingCost: 0.0, sellingFees: 0.0, additionalCosts: 0.0, shippingMethod: "", trackingReference: nil, customerShippingCharge: 0.0, deliveryMethod: .collected, revenue: 0.0, profit: 0.0, productKeyword: "Dress", quantity: 1),
            
            // This Week's Orders (25 completed, 20 incomplete)
            HardcodedOrderData(daysAgo: 1, hourOffset: 10, reference: "ORD-006", customerName: "David Wilson", status: .fulfilled, platform: .amazon, shippingCost: 5.99, sellingFees: 15.00, additionalCosts: 0.0, shippingMethod: "Amazon Prime", trackingReference: "AMZ123ABC", customerShippingCharge: 0.0, deliveryMethod: .shipped, revenue: 199.99, profit: 179.00, productKeyword: "AirPods", quantity: 1),
            HardcodedOrderData(daysAgo: 1, hourOffset: 14, reference: "ORD-007", customerName: "Sophie Turner", status: .fulfilled, platform: .ebay, shippingCost: 4.50, sellingFees: 9.25, additionalCosts: 0.0, shippingMethod: "Royal Mail", trackingReference: "RG456789123GB", customerShippingCharge: 5.99, deliveryMethod: .shipped, revenue: 94.99, profit: 81.24, productKeyword: "Sneakers", quantity: 1),
            HardcodedOrderData(daysAgo: 1, hourOffset: 16, reference: "ORD-008", customerName: "Oliver Smith", status: .shipped, platform: .amazon, shippingCost: 3.99, sellingFees: 7.50, additionalCosts: 0.0, shippingMethod: "DPD", trackingReference: "DPD456789123", customerShippingCharge: 4.99, deliveryMethod: .shipped, revenue: 0.0, profit: 0.0, productKeyword: "Watch", quantity: 1),
            HardcodedOrderData(daysAgo: 2, hourOffset: 9, reference: "ORD-009", customerName: "Isabella Garcia", status: .fulfilled, platform: .etsy, shippingCost: 2.50, sellingFees: 4.75, additionalCosts: 0.0, shippingMethod: "Standard", trackingReference: nil, customerShippingCharge: 3.99, deliveryMethod: .shipped, revenue: 56.99, profit: 49.74, productKeyword: "Bracelet", quantity: 3),
            HardcodedOrderData(daysAgo: 2, hourOffset: 11, reference: "ORD-010", customerName: "Noah Johnson", status: .fulfilled, platform: .amazon, shippingCost: 6.99, sellingFees: 18.50, additionalCosts: 2.00, shippingMethod: "Amazon Prime", trackingReference: "AMZ789DEF", customerShippingCharge: 0.0, deliveryMethod: .shipped, revenue: 249.99, profit: 222.50, productKeyword: "Samsung", quantity: 1),
            
            // Continue with more hardcoded data for the remaining 90 orders...
            // This Week (continuing)
            HardcodedOrderData(daysAgo: 2, hourOffset: 15, reference: "ORD-011", customerName: "Ava Martinez", status: .processing, platform: .marketplace, shippingCost: 0.0, sellingFees: 0.0, additionalCosts: 0.0, shippingMethod: "", trackingReference: nil, customerShippingCharge: 0.0, deliveryMethod: .collected, revenue: 0.0, profit: 0.0, productKeyword: "Jacket", quantity: 1),
            HardcodedOrderData(daysAgo: 3, hourOffset: 8, reference: "ORD-012", customerName: "William Anderson", status: .fulfilled, platform: .ebay, shippingCost: 5.50, sellingFees: 11.25, additionalCosts: 0.0, shippingMethod: "Hermes", trackingReference: "HER123456", customerShippingCharge: 6.50, deliveryMethod: .shipped, revenue: 119.99, profit: 102.74, productKeyword: "Headphones", quantity: 1),
            HardcodedOrderData(daysAgo: 3, hourOffset: 12, reference: "ORD-013", customerName: "Charlotte Taylor", status: .fulfilled, platform: .amazon, shippingCost: 4.99, sellingFees: 9.75, additionalCosts: 0.0, shippingMethod: "Amazon Logistics", trackingReference: "AMZL789", customerShippingCharge: 0.0, deliveryMethod: .shipped, revenue: 98.99, profit: 84.25, productKeyword: "Power Bank", quantity: 2),
            HardcodedOrderData(daysAgo: 3, hourOffset: 17, reference: "ORD-014", customerName: "Benjamin White", status: .canceled, platform: .etsy, shippingCost: 0.0, sellingFees: 0.0, additionalCosts: 0.0, shippingMethod: "", trackingReference: nil, customerShippingCharge: 0.0, deliveryMethod: .collected, revenue: 0.0, profit: 0.0, productKeyword: "Ring", quantity: 1),
            HardcodedOrderData(daysAgo: 4, hourOffset: 10, reference: "ORD-015", customerName: "Mia Thompson", status: .fulfilled, platform: .amazon, shippingCost: 3.99, sellingFees: 8.50, additionalCosts: 0.0, shippingMethod: "Royal Mail", trackingReference: "RG789123456GB", customerShippingCharge: 4.99, deliveryMethod: .shipped, revenue: 89.99, profit: 77.50, productKeyword: "USB", quantity: 3),
            
            // This Month (continuing with more orders)
            HardcodedOrderData(daysAgo: 7, hourOffset: 9, reference: "ORD-016", customerName: "Henry Harris", status: .fulfilled, platform: .ebay, shippingCost: 7.99, sellingFees: 19.50, additionalCosts: 1.50, shippingMethod: "UPS", trackingReference: "UPS123789", customerShippingCharge: 8.99, deliveryMethod: .shipped, revenue: 299.99, profit: 270.00, productKeyword: "Apple", quantity: 1),
            HardcodedOrderData(daysAgo: 8, hourOffset: 14, reference: "ORD-017", customerName: "Amelia Clark", status: .fulfilled, platform: .marketplace, shippingCost: 4.50, sellingFees: 6.75, additionalCosts: 0.0, shippingMethod: "DPD", trackingReference: "DPD456123", customerShippingCharge: 5.99, deliveryMethod: .shipped, revenue: 79.99, profit: 68.74, productKeyword: "Shoes", quantity: 1),
            HardcodedOrderData(daysAgo: 10, hourOffset: 11, reference: "ORD-018", customerName: "Alexander Lewis", status: .received, platform: .amazon, shippingCost: 0.0, sellingFees: 0.0, additionalCosts: 0.0, shippingMethod: "", trackingReference: nil, customerShippingCharge: 0.0, deliveryMethod: .collected, revenue: 0.0, profit: 0.0, productKeyword: "Keyboard", quantity: 1),
            HardcodedOrderData(daysAgo: 12, hourOffset: 16, reference: "ORD-019", customerName: "Harper Walker", status: .fulfilled, platform: .etsy, shippingCost: 3.25, sellingFees: 5.50, additionalCosts: 0.0, shippingMethod: "Standard", trackingReference: nil, customerShippingCharge: 4.50, deliveryMethod: .shipped, revenue: 64.99, profit: 55.74, productKeyword: "Scarf", quantity: 2),
            HardcodedOrderData(daysAgo: 15, hourOffset: 13, reference: "ORD-020", customerName: "Sebastian Hall", status: .fulfilled, platform: .amazon, shippingCost: 5.99, sellingFees: 12.75, additionalCosts: 0.0, shippingMethod: "Amazon Prime", trackingReference: "AMZ456GHI", customerShippingCharge: 0.0, deliveryMethod: .shipped, revenue: 159.99, profit: 141.25, productKeyword: "Mouse", quantity: 1),
            
            // Adding 80 more orders to reach 100 total...
            // I'll create a representative sample that covers the year
            HardcodedOrderData(daysAgo: 20, hourOffset: 10, reference: "ORD-021", customerName: "Victoria Allen", status: .fulfilled, platform: .ebay, shippingCost: 4.99, sellingFees: 8.25, additionalCosts: 0.0, shippingMethod: "Royal Mail", trackingReference: "RG321654987GB", customerShippingCharge: 5.50, deliveryMethod: .shipped, revenue: 94.99, profit: 81.25, productKeyword: "Converse", quantity: 1),
            HardcodedOrderData(daysAgo: 25, hourOffset: 15, reference: "ORD-022", customerName: "Jack Young", status: .processing, platform: .marketplace, shippingCost: 0.0, sellingFees: 0.0, additionalCosts: 0.0, shippingMethod: "", trackingReference: nil, customerShippingCharge: 0.0, deliveryMethod: .collected, revenue: 0.0, profit: 0.0, productKeyword: "T-Shirt", quantity: 2),
            HardcodedOrderData(daysAgo: 30, hourOffset: 12, reference: "ORD-023", customerName: "Madison King", status: .fulfilled, platform: .amazon, shippingCost: 6.50, sellingFees: 15.25, additionalCosts: 1.00, shippingMethod: "Amazon Logistics", trackingReference: "AMZL456", customerShippingCharge: 0.0, deliveryMethod: .shipped, revenue: 189.99, profit: 167.24, productKeyword: "Tablet", quantity: 1),
            HardcodedOrderData(daysAgo: 35, hourOffset: 9, reference: "ORD-024", customerName: "Luke Wright", status: .fulfilled, platform: .etsy, shippingCost: 2.99, sellingFees: 4.25, additionalCosts: 0.0, shippingMethod: "Standard", trackingReference: nil, customerShippingCharge: 3.99, deliveryMethod: .shipped, revenue: 49.99, profit: 42.75, productKeyword: "Wallet", quantity: 1),
            HardcodedOrderData(daysAgo: 40, hourOffset: 14, reference: "ORD-025", customerName: "Grace Lopez", status: .shipped, platform: .amazon, shippingCost: 4.50, sellingFees: 9.75, additionalCosts: 0.0, shippingMethod: "DPD", trackingReference: "DPD789456", customerShippingCharge: 5.99, deliveryMethod: .shipped, revenue: 0.0, profit: 0.0, productKeyword: "Camera", quantity: 1),
            
            // Continue with remaining orders to reach 100...
            // I'll add a condensed version for the remaining 75 orders
        ] + generateRemainingHardcodedOrders() + generateFutureOrders()
    }
    
    private func generateRemainingHardcodedOrders() -> [HardcodedOrderData] {
        // Generate the remaining 75 orders with varied data
        var remainingOrders: [HardcodedOrderData] = []
        let customers = ["Ryan Hill", "Zoe Green", "Tyler Adams", "Chloe Baker", "Mason Gonzalez", "Lily Nelson", "Ethan Carter", "Stella Mitchell", "Logan Perez", "Nora Roberts"]
        let platforms: [Platform] = [.amazon, .ebay, .etsy, .marketplace, .vinted]
        let statuses: [OrderStatus] = [.fulfilled, .fulfilled, .fulfilled, .processing, .pending, .shipped, .received, .canceled]
        let productKeywords = ["iPhone", "Jordan", "MacBook", "AirPods", "Watch", "Headphones", "Tablet", "Camera", "Dress", "Jacket"]
        
        for i in 0..<75 {
            let orderNum = i + 26
            let daysAgo = 45 + (i * 4) // Spread across the year
            let isCompleted = i < 37 // First 37 are completed (total 50 completed with the first 25)
            let status = isCompleted ? .fulfilled : statuses[i % statuses.count]
            
            let revenue = isCompleted ? Double.random(in: 45...450) : 0.0
            let shippingCost = isCompleted ? Double.random(in: 2.99...7.99) : 0.0
            let sellingFees = isCompleted ? revenue * 0.08 : 0.0
            let profit = isCompleted ? revenue - shippingCost - sellingFees : 0.0
            
            remainingOrders.append(HardcodedOrderData(
                daysAgo: daysAgo,
                hourOffset: (i * 3) % 24,
                reference: String(format: "ORD-%03d", orderNum),
                customerName: customers[i % customers.count],
                status: status,
                platform: platforms[i % platforms.count],
                shippingCost: shippingCost,
                sellingFees: sellingFees,
                additionalCosts: 0.0,
                shippingMethod: isCompleted ? "Royal Mail" : "",
                trackingReference: isCompleted ? "TRK\(orderNum)" : nil,
                customerShippingCharge: isCompleted ? Double.random(in: 3.99...8.99) : 0.0,
                deliveryMethod: .shipped,
                revenue: revenue,
                profit: profit,
                productKeyword: productKeywords[i % productKeywords.count],
                quantity: Int.random(in: 1...3)
            ))
        }
        
        return remainingOrders
    }
    
    private func generateFutureOrders() -> [HardcodedOrderData] {
        // Generate future orders with "received" status but not concluded
        let futureCustomers = ["Alex Thompson", "Jessica Lee", "Marcus Wilson", "Sophie Clark", "Daniel Rodriguez", "Emma Davis", "Ryan Martinez", "Olivia Garcia", "Lucas Anderson", "Maya Patel"]
        let platforms: [Platform] = [.amazon, .ebay, .etsy, .marketplace, .vinted]
        let productKeywords = ["iPhone", "Jordan", "Sneakers", "Watch", "Headphones", "Jacket", "Tablet", "Camera", "Bag", "Sunglasses"]
        
        var futureOrders: [HardcodedOrderData] = []
        
        // Generate 8 future orders spread over the next 2 weeks
        for i in 0..<8 {
            let orderNum = 101 + i // Continue from where other orders end
            let daysInFuture = -((i % 4) + 1) // -1, -2, -3, -4 days (future dates)
            let hourOffset = (i * 3 + 8) % 24 // Spread throughout the day
            
            futureOrders.append(HardcodedOrderData(
                daysAgo: daysInFuture, // Negative values for future dates
                hourOffset: hourOffset,
                reference: String(format: "ORD-%03d", orderNum),
                customerName: futureCustomers[i % futureCustomers.count],
                status: .received, // Received but not concluded
                platform: platforms[i % platforms.count],
                shippingCost: 0.0, // Not yet processed
                sellingFees: 0.0, // Not yet processed
                additionalCosts: 0.0,
                shippingMethod: "", // Not yet determined
                trackingReference: nil, // Not yet shipped
                customerShippingCharge: 0.0,
                deliveryMethod: .collected, // Default, not yet determined
                revenue: 0.0, // Not yet concluded
                profit: 0.0, // Not yet concluded
                productKeyword: productKeywords[i % productKeywords.count],
                quantity: Int.random(in: 1...2)
            ))
        }
        
        return futureOrders
    }
    
    private func generateRandomDateWithinYear() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Create clusters of orders on certain days for realism
        // 60% chance of being on a "busy" day, 40% chance of random date
        if Double.random(in: 0...1) < 0.6 {
            // Pick from common business days (weighted toward recent dates)
            let busyDays = [0, 1, 2, 3, 5, 7, 10, 14, 21, 30, 45, 60, 90, 120, 180, 270, 365]
            let daysAgo = busyDays.randomElement() ?? 0
            
            // Add random hours/minutes to the day for variety
            let hoursOffset = Int.random(in: 0...23)
            let minutesOffset = Int.random(in: 0...59)
            
            var date = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            date = calendar.date(byAdding: .hour, value: hoursOffset, to: date) ?? date
            date = calendar.date(byAdding: .minute, value: minutesOffset, to: date) ?? date
            
            return date
        } else {
            // Random date for variety
            let daysAgo = Int.random(in: 0...365)
            let hoursOffset = Int.random(in: 0...23)
            let minutesOffset = Int.random(in: 0...59)
            
            var date = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            date = calendar.date(byAdding: .hour, value: hoursOffset, to: date) ?? date
            date = calendar.date(byAdding: .minute, value: minutesOffset, to: date) ?? date
            
            return date
        }
    }
    
    private func generateIncompleteStatus() -> OrderStatus {
     //   let incompleteStatuses: [OrderStatus] = [.received, .pending, .processing, .shipped, .canceled]
        let weights: [(OrderStatus, Int)] = [
            (.received, 25),    // 25% - New orders
            (.pending, 20),     // 20% - Awaiting payment/confirmation
            (.processing, 30),  // 30% - Being prepared
            (.shipped, 20),     // 20% - On the way
            (.canceled, 5)     // 5% - Cancelled orders
        ]
        return weightedRandomChoice(weights)
    }
    
    func generateDummyCategories() -> [Category] {
        return categoryData.map { categoryInfo in
            Category(
                name: categoryInfo.name,
                colorHex: categoryInfo.color
            )
        }
    }
    
    private func generateDummyStockItems() -> [StockItem] {
        let categories = generateDummyCategories()
        
        return productNames.enumerated().map { index, name in
            let cost = Double.random(in: 5...400) // Higher cost range to reach £500 cap
            let markup = Double.random(in: 1.05...1.25) // 5% to 25% markup (smaller margins)
            let rawPrice = cost * markup
            let price = min(rawPrice, 500.0) // Cap at £500
            
            let stockItem = StockItem(
                name: name,
                quantityAvailable: Int.random(in: 0...50),
                price: Double(String(format: "%.2f", price)) ?? price,
                cost: Double(String(format: "%.2f", cost)) ?? cost,
                currency: .gbp,
                attributes: generateRandomAttributes()
            )
            
            // Assign appropriate category based on product name
            stockItem.category = getCategoryForProduct(name: name, categories: categories)
            
            return stockItem
        }
    }
    
    private func getCategoryForProduct(name: String, categories: [Category]) -> Category? {
        let lowercaseName = name.lowercased()
        
        // Electronics
        if lowercaseName.contains("iphone") || lowercaseName.contains("samsung") || 
           lowercaseName.contains("apple") || lowercaseName.contains("macbook") ||
           lowercaseName.contains("airpods") || lowercaseName.contains("headphones") ||
           lowercaseName.contains("watch") || lowercaseName.contains("charger") ||
           lowercaseName.contains("speaker") || lowercaseName.contains("mouse") ||
           lowercaseName.contains("keyboard") || lowercaseName.contains("usb") ||
           lowercaseName.contains("power bank") || lowercaseName.contains("hub") ||
           lowercaseName.contains("stand") || lowercaseName.contains("grip") ||
           lowercaseName.contains("tracker") || lowercaseName.contains("earbuds") {
            return categories.first { $0.name == "Electronics" }
        }
        
        // Footwear
        else if lowercaseName.contains("jordan") || lowercaseName.contains("sneakers") ||
                lowercaseName.contains("shoes") || lowercaseName.contains("boots") ||
                lowercaseName.contains("ultraboost") || lowercaseName.contains("converse") ||
                lowercaseName.contains("vans") || lowercaseName.contains("yeezy") ||
                lowercaseName.contains("dunk") || lowercaseName.contains("new balance") ||
                lowercaseName.contains("timberland") || lowercaseName.contains("balenciaga") ||
                lowercaseName.contains("running") {
            return categories.first { $0.name == "Footwear" }
        }
        
        // Clothing
        else if lowercaseName.contains("hoodie") || lowercaseName.contains("jeans") ||
                lowercaseName.contains("jacket") || lowercaseName.contains("shirt") ||
                lowercaseName.contains("champion") || lowercaseName.contains("north face") ||
                lowercaseName.contains("supreme") || lowercaseName.contains("carhartt") ||
                lowercaseName.contains("off-white") || lowercaseName.contains("cap") ||
                lowercaseName.contains("beanie") {
            return categories.first { $0.name == "Clothing" }
        }
        
        // Gaming
        else if lowercaseName.contains("gaming") || lowercaseName.contains("mouse") ||
                lowercaseName.contains("mechanical keyboard") {
            return categories.first { $0.name == "Gaming" }
        }
        
        // Sports
        else if lowercaseName.contains("fitness") || lowercaseName.contains("yoga") ||
                lowercaseName.contains("protein") || lowercaseName.contains("gym") ||
                lowercaseName.contains("running") {
            return categories.first { $0.name == "Sports" }
        }
        
        // Accessories
        else if lowercaseName.contains("sunglasses") || lowercaseName.contains("watch") ||
                lowercaseName.contains("wallet") || lowercaseName.contains("bag") ||
                lowercaseName.contains("belt") || lowercaseName.contains("backpack") ||
                lowercaseName.contains("case") || lowercaseName.contains("ray-ban") ||
                lowercaseName.contains("fossil") || lowercaseName.contains("gucci") ||
                lowercaseName.contains("louis vuitton") || lowercaseName.contains("chanel") {
            return categories.first { $0.name == "Accessories" }
        }
        
        // Vintage (for luxury watches and vintage items)
        else if lowercaseName.contains("vintage") || lowercaseName.contains("rolex") ||
                lowercaseName.contains("omega") || lowercaseName.contains("vinyl") {
            return categories.first { $0.name == "Vintage" }
        }
        
        // Default to random category if no specific match
        return categories.randomElement()
    }
    
    private func generateSingleOrder(index: Int, date: Date, availableStockItems: [StockItem]) -> Order {
        let platforms = Platform.allCases
      //  let statuses = OrderStatus.allCases
       // let deliveryMethods = DeliveryMethod.allCases
        
        // Create order items (1-4 items per order)
        let itemCount = Int.random(in: 1...4)
        var orderItems: [OrderItem] = []
        var totalRevenue: Double = 0
        var totalCost: Double = 0
        
        for _ in 0..<itemCount {
            let stockItem = availableStockItems.randomElement()!
            let quantity = Int.random(in: 1...3)
            
            let orderItem = OrderItem(quantity: quantity, stockItem: stockItem)
            orderItems.append(orderItem)
            
            totalRevenue += stockItem.price * Double(quantity)
            totalCost += stockItem.cost * Double(quantity)
        }
        
        // Add shipping and fees
        let shippingCost = Double.random(in: 0...15)
        let sellingFees = totalRevenue * Double.random(in: 0.05...0.15) // 5-15% selling fees
        let additionalCosts = Bool.random() ? Double.random(in: 0...5) : 0
        let customerShippingCharge = Double.random(in: 0...12)
        
        totalCost += shippingCost + additionalCosts
        totalRevenue += customerShippingCharge
        
       // let profit = totalRevenue - totalCost - sellingFees
        
        let order = Order(
            orderReceivedDate: date,
            orderReference: generateOrderReference(index: index, platform: platforms.randomElement()!),
            customerName: customerNames.randomElement()!,
            status: generateRealisticStatus(for: date),
            platform: platforms.randomElement()!,
            shippingCost: shippingCost,
            sellingFees: sellingFees
        )
        
        return order
    }
    
    private func generateOrderReference(index: Int, platform: Platform) -> String {
        switch platform {
        case .ebay:
            return "EB-\(String(format: "%06d", 100000 + index))"
        case .amazon:
            return "AMZ-\(String(format: "%03d", Int.random(in: 100...999)))-\(String(format: "%07d", 1000000 + index))"
        case .vinted:
            return "VT\(String(format: "%08d", 10000000 + index))"
        case .shopify:
            return "#\(String(format: "%04d", 1000 + index))"
        case .etsy:
            return "ET\(String(format: "%010d", 1000000000 + index))"
        case .depop:
            return "DP\(String(format: "%07d", 1000000 + index))"
        default:
            return "ORD-\(String(format: "%05d", 10000 + index))"
        }
    }
    
    private func generateTrackingReference() -> String? {
        guard Bool.random() else { return nil } // 50% chance of having tracking
        
        let prefixes = ["TN", "CP", "RR", "EE", "CJ", "LZ"]
        let prefix = prefixes.randomElement()!
        let numbers = String(format: "%09d", Int.random(in: 100000000...999999999))
        let suffix = "GB"
        
        return "\(prefix)\(numbers)\(suffix)"
    }
    
    private func generateRealisticStatus(for date: Date) -> OrderStatus {
        let daysSinceOrder = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        
        // More recent orders are more likely to be in earlier stages, but some can be fulfilled for Dashboard metrics
        switch daysSinceOrder {
        case 0...2:
            // Today/Yesterday: Mix of statuses but include some fulfilled for Dashboard
            let weights: [(OrderStatus, Int)] = [
                (.received, 30),
                (.pending, 20),
                (.processing, 25),
                (.shipped, 15),
                (.fulfilled, 10) // Some quick fulfillment for Dashboard metrics
            ]
            return weightedRandomChoice(weights)
        case 3...7:
            // This week: More likely to be shipped/delivered, some fulfilled
            let weights: [(OrderStatus, Int)] = [
                (.processing, 20),
                (.shipped, 30),
                (.delivered, 25),
                (.fulfilled, 25) // Good portion fulfilled for Dashboard
            ]
            return weightedRandomChoice(weights)
        case 8...30:
            // This month: Most should be delivered/fulfilled
            let weights: [(OrderStatus, Int)] = [
                (.delivered, 30),
                (.fulfilled, 60), // Majority fulfilled
                (.returned, 8),
                (.refunded, 2)
            ]
            return weightedRandomChoice(weights)
        default:
            // Older orders are mostly fulfilled with occasional returns/refunds
            let weights: [(OrderStatus, Int)] = [
                (.fulfilled, 80),
                (.delivered, 10),
                (.returned, 5),
                (.refunded, 3),
                (.canceled, 2)
            ]
            return weightedRandomChoice(weights)
        }
    }
    
    private func weightedRandomChoice<T>(_ choices: [(T, Int)]) -> T {
        let totalWeight = choices.reduce(0) { $0 + $1.1 }
        let randomValue = Int.random(in: 0..<totalWeight)
        
        var currentWeight = 0
        for (choice, weight) in choices {
            currentWeight += weight
            if randomValue < currentWeight {
                return choice
            }
        }
        return choices.first!.0
    }
    
    private func generateRandomAttributes() -> [String: String] {
        var attributes: [String: String] = [:]
        
        // Randomly add some attributes
        if Bool.random() {
            attributes["Color"] = ["Black", "White", "Red", "Blue", "Green", "Navy", "Grey"].randomElement()!
        }
        if Bool.random() {
            attributes["Size"] = ["XS", "S", "M", "L", "XL", "XXL", "6", "7", "8", "9", "10", "11", "12"].randomElement()!
        }
        if Bool.random() {
            attributes["Condition"] = ["New", "Like New", "Good", "Fair", "Vintage"].randomElement()!
        }
        if Bool.random() {
            attributes["Brand"] = ["Nike", "Adidas", "Apple", "Samsung", "Sony", "Unbranded"].randomElement()!
        }
        
        return attributes
    }
    
    private func findAlternativeStockItem(for keyword: String, in stockItems: [StockItem]) -> StockItem? {
        let lowercaseKeyword = keyword.lowercased()
        
        // Alternative matching for common keywords
        switch lowercaseKeyword {
        case "iphone":
            return stockItems.first { $0.name.lowercased().contains("iphone") || $0.name.lowercased().contains("apple") }
        case "jordan":
            return stockItems.first { $0.name.lowercased().contains("jordan") || $0.name.lowercased().contains("nike") }
        case "macbook":
            return stockItems.first { $0.name.lowercased().contains("macbook") || $0.name.lowercased().contains("laptop") }
        case "airpods":
            return stockItems.first { $0.name.lowercased().contains("airpods") || $0.name.lowercased().contains("earbuds") }
        case "watch":
            return stockItems.first { $0.name.lowercased().contains("watch") || $0.name.lowercased().contains("apple") }
        case "headphones":
            return stockItems.first { $0.name.lowercased().contains("headphones") || $0.name.lowercased().contains("sony") }
        case "tablet":
            return stockItems.first { $0.name.lowercased().contains("ipad") || $0.name.lowercased().contains("tablet") }
        case "camera":
            return stockItems.first { $0.name.lowercased().contains("camera") || $0.name.lowercased().contains("lens") }
        case "dress", "jacket", "t-shirt":
            return stockItems.first { item in
                ["hoodie", "jacket", "tee", "shirt", "jeans"].contains { item.name.lowercased().contains($0) }
            }
        case "shoes", "sneakers":
            return stockItems.first { item in
                ["sneakers", "shoes", "boots", "converse", "vans", "nike"].contains { item.name.lowercased().contains($0) }
            }
        case "necklace", "bracelet", "ring", "scarf", "wallet":
            return stockItems.first { item in
                ["wallet", "bag", "belt", "watch", "sunglasses"].contains { item.name.lowercased().contains($0) }
            }
        case "usb", "power bank", "keyboard", "mouse":
            return stockItems.first { item in
                ["mouse", "keyboard", "charger", "usb", "power", "speaker", "hub"].contains { item.name.lowercased().contains($0) }
            }
        case "samsung", "apple":
            return stockItems.first { $0.name.lowercased().contains(lowercaseKeyword) }
        case "converse":
            return stockItems.first { $0.name.lowercased().contains("converse") || $0.name.lowercased().contains("chuck") }
        default:
            return nil
        }
    }
}
