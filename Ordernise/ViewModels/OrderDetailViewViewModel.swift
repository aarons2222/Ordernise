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
        var attributes: [AttributeField] = []
        
        var isValid: Bool {
            guard let item = stockItem else { return false }
            return quantity > 0 && quantity <= item.quantityAvailable
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
    
    struct AttributeField: Identifiable {
        let id = UUID()
        var key: String = ""
        var value: String = ""
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
    func updateStockItem(_ stockItem: StockItem, quantity: Int, attributes: [AttributeField]) {
        print("🔄 ViewModel: updateStockItem called for \(stockItem.name)")
        print("   Quantity: \(quantity), Attributes: \(attributes.count)")
        
        // Log each attribute for debugging
        for attr in attributes {
            print("   - \(attr.key): \(attr.value)")
        }
        
        // Check if this item already exists in the order
        if let existingIndex = orderItems.firstIndex(where: { $0.stockItem?.id == stockItem.id }) {
            if quantity == 0 {
                // Remove item if quantity is 0
                print("🗑️ ViewModel: Removing item \(stockItem.name)")
                orderItems.remove(at: existingIndex)
            } else {
                // Update existing item
                print("⚙️ ViewModel: Updating existing item \(stockItem.name) with \(attributes.count) attributes")
                orderItems[existingIndex].quantity = quantity
                orderItems[existingIndex].attributes = attributes
            }
        } else if quantity > 0 {
            // Add new item (only if quantity > 0)
            print("➕ ViewModel: Adding new item \(stockItem.name) with \(attributes.count) attributes")
            let newOrderItem = OrderItemEntry(
                stockItem: stockItem,
                quantity: quantity,
                attributes: attributes
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
    
    /// Get existing attributes for StockItemPickerView initialization
    func getExistingAttributes() -> [StockItem.ID: [AttributeField]] {
        var attributes: [StockItem.ID: [AttributeField]] = [:]
        for orderItem in orderItems {
            if let stockItem = orderItem.stockItem {
                attributes[stockItem.id] = orderItem.attributes
                print("📝 ViewModel: Item \(stockItem.name) has \(orderItem.attributes.count) attributes")
                for attr in orderItem.attributes {
                    print("   - \(attr.key): \(attr.value)")
                }
            }
        }
        return attributes
    }
    
    /// Load existing order data for edit mode
    func loadOrderData(from order: Order) {
        print("📥 ViewModel: Loading order data for order \(order.id)")
        
        var loadedItems: [OrderItemEntry] = []
        
        for orderItem in order.items {
            if let stockItem = orderItem.stockItem {
                // Convert order item attributes to AttributeField
                let attributeFields = orderItem.attributes.map { key, value in
                    AttributeField(key: key, value: value)
                }
                
                let entry = OrderItemEntry(
                    stockItem: stockItem,
                    quantity: orderItem.quantity,
                    attributes: attributeFields
                )
                loadedItems.append(entry)
                
                print("📦 ViewModel: Loaded item \(stockItem.name) - qty: \(orderItem.quantity), attrs: \(attributeFields.count)")
                for attr in attributeFields {
                    print("   - \(attr.key): \(attr.value)")
                }
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
                print("   [\(index)] \(stockItem.name) - qty: \(item.quantity), attrs: \(item.attributes.count)")
                for attr in item.attributes {
                    print("      - \(attr.key): \(attr.value)")
                }
            }
        }
    }
}
