import SwiftUI
import SwiftData
internal import Combine

@MainActor
class StockManager: ObservableObject {
    private var modelContext: ModelContext
    
    // Track pending stock changes that haven't been committed yet
    @Published private var pendingChanges: [StockItem.ID: Int] = [:]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Stock Availability Calculations
    
    /// Get the actual available quantity for a stock item, accounting for pending changes
    func getAvailableQuantity(for stockItem: StockItem, existingAllocation: Int = 0) -> Int {
        let pendingDelta = pendingChanges[stockItem.id] ?? 0
        // Available = base stock + existing allocation - pending delta
        return stockItem.quantityAvailable + existingAllocation - pendingDelta
    }
    
    /// Get the current pending allocation delta for a stock item
    func getPendingAllocationDelta(for stockItem: StockItem) -> Int {
        return pendingChanges[stockItem.id] ?? 0
    }
    
    // MARK: - Pending Changes Management
    
    /// Set a pending stock allocation (doesn't commit to database)
    /// Tracks the DELTA from existing allocation, not absolute quantity
    func setPendingAllocation(for stockItem: StockItem, quantity: Int, existingAllocation: Int = 0) {
        // Calculate delta from existing allocation
        let delta = quantity - existingAllocation
        
        // Validate the delta doesn't exceed available stock
        let maxDelta = stockItem.quantityAvailable
        let clampedDelta = min(max(-existingAllocation, delta), maxDelta)
        
        if clampedDelta == 0 {
            pendingChanges.removeValue(forKey: stockItem.id)
        } else {
            pendingChanges[stockItem.id] = clampedDelta
        }
    }
    
    /// Clear all pending changes without committing
    func clearPendingChanges() {
        pendingChanges.removeAll()
    }
    
    /// Get all items with pending allocations
    func getItemsWithPendingChanges() -> [StockItem.ID: Int] {
        return pendingChanges
    }
    
    // MARK: - Stock Operations
    
    /// Commit pending stock allocations to the database
    func commitPendingChanges() throws {
        for (stockItemId, allocatedQuantity) in pendingChanges {
            // Find the stock item in the model contextNo
            let fetchDescriptor = FetchDescriptor<StockItem>(
                predicate: #Predicate { $0.id == stockItemId }
            )
            
            if let stockItem = try modelContext.fetch(fetchDescriptor).first {
                stockItem.quantityAvailable = max(0, stockItem.quantityAvailable - allocatedQuantity)
            }
        }
        
        try modelContext.save()
        clearPendingChanges()
    }
    
    /// Set absolute stock quantity (for stock item creation/editing)
    func setStockQuantity(for stockItem: StockItem, quantity: Int) throws {
        stockItem.quantityAvailable = max(0, quantity)
        try modelContext.save()
    }
    
    /// Adjust stock quantity by a relative amount (positive = add stock, negative = remove stock)
    func adjustStockQuantity(for stockItem: StockItem, adjustment: Int) throws {
        let newQuantity = stockItem.quantityAvailable + adjustment
        stockItem.quantityAvailable = max(0, newQuantity)
        try modelContext.save()
    }
    
    /// Restore stock quantities (used when orders are deleted)
    func restoreStock(for orderItems: [OrderItem]) throws {
        for orderItem in orderItems {
            if let stockItem = orderItem.stockItem {
                stockItem.quantityAvailable += orderItem.quantity
            }
        }
        try modelContext.save()
    }
    
    /// Update stock when order quantities are modified
    func updateStockForOrderChange(
        stockItem: StockItem,
        oldQuantity: Int,
        newQuantity: Int
    ) throws {
        let difference = newQuantity - oldQuantity
        stockItem.quantityAvailable -= difference
        try modelContext.save()
    }
    
    // MARK: - Validation
    
    /// Check if a stock allocation is valid
    func canAllocate(stockItem: StockItem, quantity: Int) -> Bool {
        let availableQuantity = getAvailableQuantity(for: stockItem)
        return quantity <= availableQuantity && quantity >= 0
    }
    
    /// Get maximum allocatable quantity for a stock item
    func getMaxAllocatable(for stockItem: StockItem) -> Int {
        return getAvailableQuantity(for: stockItem)
    }
}

// MARK: - Environment Key
struct StockManagerKey: EnvironmentKey {
    static let defaultValue: StockManager? = nil
}

extension EnvironmentValues {
    var stockManager: StockManager? {
        get { self[StockManagerKey.self] }
        set { self[StockManagerKey.self] = newValue }
    }
}
