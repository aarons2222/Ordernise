import SwiftUI
import SwiftData
internal import Combine

@MainActor
class OrderDetailViewViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var orderItems: [OrderItemEntry] = []
    
    // MARK: - Types
    struct OrderItemEntry: Identifiable {
        let id = UUID()
        var stockItem: StockItem?
        var quantity: Int = 1
        var isFromExistingOrder: Bool = false
    
        
        var isValid: Bool {
            guard let item = stockItem else { return false }
            // For existing order items, only check quantity > 0
            // For new items, check both quantity > 0 and stock availability
            if isFromExistingOrder {
                return quantity > 0
            } else {
                return quantity > 0 && quantity <= item.quantityAvailable
            }
        }
        
        var hasInsufficientStock: Bool {
            guard let item = stockItem else { return false }
            return quantity > item.quantityAvailable
        }
        
        var totalPrice: Double {
            guard let item = stockItem else { return 0.0 }
            return item.price * Double(quantity)
        }
    }

    
    // MARK: - Computed Properties
    var totalItemsPrice: Double {
        orderItems.filter { $0.isValid }.reduce(0) { $0 + $1.totalPrice }
    }
    
    var validOrderItems: [OrderItemEntry] {
        orderItems.filter { $0.isValid }
    }
    
    var hasValidItems: Bool {
        !orderItems.isEmpty && orderItems.allSatisfy { $0.isValid }
    }
    
    // MARK: - Public Methods
    
    /// Main method to handle stock item selection/updates from StockItemPickerView
    func updateStockItem(_ stockItem: StockItem, quantity: Int) {
        print("🔄 ViewModel: updateStockItem called for \(stockItem.name)")

   
        
        // Check if this item already exists in the order
        if let existingIndex = orderItems.firstIndex(where: { $0.stockItem?.id == stockItem.id }) {
            if quantity == 0 {
                // Remove item if quantity is 0
                print("🗑️ ViewModel: Removing item \(stockItem.name)")
                orderItems.remove(at: existingIndex)
            } else {
                // Update existing item
                print("⚙️ ViewModel: Updating existing item \(stockItem.name)")
                orderItems[existingIndex].quantity = quantity
            }
        } else if quantity > 0 {
            // Add new item (only if quantity > 0)
            print("➕ ViewModel: Adding new item \(stockItem.name) with ")
            let newOrderItem = OrderItemEntry(
                stockItem: stockItem,
                quantity: quantity,
            )
            orderItems.append(newOrderItem)
        }
        
        print("✅ ViewModel: Final orderItems count: \(orderItems.count)")
        logCurrentState()
    }
    
    /// Get existing quantities for StockItemPickerView initialization
    func getExistingQuantities() -> [StockItem.ID: Int] {
        var quantities: [StockItem.ID: Int] = [:]
        for orderItem in orderItems {
            if let stockItem = orderItem.stockItem {
                quantities[stockItem.id] = orderItem.quantity
            }
        }
        return quantities
    }
    

    /// Load existing order data for edit mode
    func loadOrderData(from order: Order) {
        print("📥 ViewModel: Loading order data for order \(order.id)")
        
        var loadedItems: [OrderItemEntry] = []
        
        for orderItem in order.items ?? [] {
            if let stockItem = orderItem.stockItem {
            
                let entry = OrderItemEntry(
                    stockItem: stockItem,
                    quantity: orderItem.quantity,
                    isFromExistingOrder: true
                )
                loadedItems.append(entry)
                
                print("📦 ViewModel: Loaded item \(stockItem.name) - qty: \(orderItem.quantity)")
              
            }
        }
        
        orderItems = loadedItems
        print("✅ ViewModel: Loaded \(orderItems.count) order items")
        logCurrentState()
    }
    
    /// Clear all order items
    func clearAllItems() {
        print("🧹 ViewModel: Clearing all order items")
        orderItems.removeAll()
    }
    
    /// Remove specific order item
    func removeOrderItem(at index: Int) {
        guard index < orderItems.count else { return }
        let item = orderItems[index]
        if let stockItem = item.stockItem {
            print("🗑️ ViewModel: Removing order item \(stockItem.name)")
        }
        orderItems.remove(at: index)
        logCurrentState()
    }
    
    // MARK: - Private Methods
    
    private func logCurrentState() {
        print("📊 ViewModel: Current state:")
        print("   Total items: \(orderItems.count)")
        for (index, item) in orderItems.enumerated() {
            if let stockItem = item.stockItem {
                print("   [\(index)] \(stockItem.name) - qty: \(item.quantity)")
               
            }
        }
    }
}
