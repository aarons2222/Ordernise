 //
//  StockFieldPreferences.swift
//  Ordernise
//
//  Created by Aaron Strickland on 10/08/2025.
//

import Foundation
import SwiftData


struct CustomStockField: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var placeholder: String
    var isRequired: Bool = false
    var isVisible: Bool = true
  
    
    init(name: String, placeholder: String, isRequired: Bool = false) {
        self.name = name
        self.placeholder = placeholder
        self.isRequired = isRequired
    }
}

// MARK: - Built-in Field Definition
enum BuiltInStockField: String, Codable, CaseIterable {
    case name = "name"
    case quantityAvailable = "quantityAvailable"
    case price = "price"
    case cost = "cost"
    case category = "category"
    
    var displayName: String {
        switch self {
        case .name: return  String(localized: "Item Name") 
        case .quantityAvailable: return String(localized: "Quantity Available")
        case .price: return String(localized: "Item Price")
        case .cost: return String(localized: "Item Cost")
        case .category: return String(localized: "Category")
        }
    }
    
    
    
    
    var isRequired: Bool {
        switch self {
        case .name, .price:
            return true
        default:
            return false
        }
    }
    
    var systemImage: String {
        switch self {
        case .name: return "tag"
        case .quantityAvailable: return "number.square"
        case .price: return "dollarsign.circle"
        case .cost: return "creditcard"
        case .category: return "folder"
        }
    }
}

struct StockFieldItem: Codable, Equatable, Identifiable {
    var isBuiltIn: Bool
    var builtInField: BuiltInStockField?
    var customField: CustomStockField?
    var isVisible: Bool
    var sortOrder: Int
    
    var id: String {
        if isBuiltIn, let builtInField = builtInField {
            return builtInField.rawValue
        } else if let customField = customField {
            return "custom_\(customField.name)"
        } else {
            return "unknown"
        }
    }
    
    init(builtInField: BuiltInStockField, isVisible: Bool = true, sortOrder: Int = 0) {
        self.isBuiltIn = true
        self.builtInField = builtInField
        self.customField = nil
        self.isVisible = isVisible
        self.sortOrder = sortOrder
    }
    
    init(customField: CustomStockField, isVisible: Bool = true, sortOrder: Int = 0) {
        self.isBuiltIn = false
        self.builtInField = nil
        self.customField = customField
        self.isVisible = isVisible
        self.sortOrder = sortOrder
    }
    
    var displayName: String {
        if isBuiltIn {
            return builtInField?.displayName ?? "Unknown Field"
        } else {
            return customField?.name ?? "Unknown Field"
        }
    }
    
    var isRequired: Bool {
        if isBuiltIn {
            return builtInField?.isRequired ?? false
        } else {
            return customField?.isRequired ?? false
        }
    }
    
    var systemImage: String {
        if isBuiltIn {
            return builtInField?.systemImage ?? "questionmark"
        } else {
            return "textformat"
        }
    }
}

struct StockFieldPreferences: Codable, Equatable {
    // Field ordering and visibility
    var fieldItems: [StockFieldItem] = []
    
    static let `default` = StockFieldPreferences()
    
    // Initialize with default field configuration for new app
    init() {
        initializeDefaultFields()
    }
    
    // Predefined configurations for common use cases
//    static let minimal = StockFieldPreferences(preset: .minimal)
//    static let detailed = StockFieldPreferences(preset: .detailed)
//    static let costFocus = StockFieldPreferences(preset: .costFocus)
    
//    private init(preset: Preset) {
//        initializeDefaultFields()
//    }
    
//    private enum Preset {
//        case minimal, detailed, costFocus
//    }
//    
    // MARK: - Helper Methods
    
    /// Initialize with default field configuration
    private mutating func initializeDefaultFields() {
        fieldItems = [
            StockFieldItem(builtInField: .name, isVisible: true, sortOrder: 0),
            StockFieldItem(builtInField: .quantityAvailable, isVisible: true, sortOrder: 1),
            StockFieldItem(builtInField: .category, isVisible: true, sortOrder: 2),
            StockFieldItem(builtInField: .price, isVisible: true, sortOrder: 3),
            StockFieldItem(builtInField: .cost, isVisible: true, sortOrder: 4),
        ]
    }
    
//    /// Apply preset configuration
//    private mutating func applyPreset(_ preset: Preset) {
//        switch preset {
//        case .minimal:
//            setFieldVisibility(.cost, visible: false)
//        case .detailed:
//            // All fields visible (default)
//            break
//        case .costFocus:
//        }
//    }
//    
//    /// Helper to set field visibility
    private mutating func setFieldVisibility(_ field: BuiltInStockField, visible: Bool) {
        if let index = fieldItems.firstIndex(where: { $0.builtInField == field }) {
            fieldItems[index].isVisible = visible
        }
    }
    
    /// Adds a new custom field
    mutating func addCustomField(_ field: CustomStockField) {
        let newItem = StockFieldItem(
            customField: field,
            isVisible: true,
            sortOrder: fieldItems.count
        )
        fieldItems.append(newItem)
    }
    
    /// Removes a field by ID
    mutating func removeField(withId id: String) {
        fieldItems.removeAll { $0.id == id }
        updateSortOrders()
    }
    
    /// Updates sort orders after reordering
    mutating func updateSortOrders() {
        for (index, _) in fieldItems.enumerated() {
            fieldItems[index].sortOrder = index
        }
    }
    
    /// Gets visible fields in sort order
    var visibleFields: [StockFieldItem] {
        return fieldItems
            .filter { $0.isVisible }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Gets all fields in sort order
    var allFieldsInOrder: [StockFieldItem] {
        print("[DEBUG STOCK COMPUTED] fieldItems.count: \(fieldItems.count)")
        for item in fieldItems {
            if let builtIn = item.builtInField {
                print("[DEBUG STOCK COMPUTED] fieldItem: \(builtIn.rawValue) - sortOrder: \(item.sortOrder)")
            }
        }
        
        let sorted = fieldItems.sorted { $0.sortOrder < $1.sortOrder }
        print("[DEBUG STOCK COMPUTED] sorted.count: \(sorted.count)")
        return sorted
    }
    
    /// Check if a specific built-in field is visible
    func isFieldVisible(_ field: BuiltInStockField) -> Bool {
        return fieldItems.first(where: { $0.builtInField == field })?.isVisible ?? true
    }
}

// MARK: - UserDefaults Extension (SwiftData-backed)
extension UserDefaults {
    private enum StockKeys {
        static let stockFieldPreferences = "stockFieldPreferences"
    }
    
    var stockFieldPreferences: StockFieldPreferences {
        get {
            // Try SwiftData first (synchronously)
            if let swiftDataPrefs = loadStockFieldPreferencesSync() {
                return swiftDataPrefs
            }
            
            // Fallback to UserDefaults and migrate
            guard let data = data(forKey: StockKeys.stockFieldPreferences),
                  let preferences = try? JSONDecoder().decode(StockFieldPreferences.self, from: data) else {
                return StockFieldPreferences.default
            }
            
            // Migrate to SwiftData asynchronously
            Task { @MainActor in
                FieldPreferencesManager.shared.saveStockFieldPreferences(preferences)
                print("[UserDefaults] Migrated stock preferences to SwiftData")
            }
            
            return preferences
        }
        set {
            // Save to SwiftData (primary) asynchronously
            Task { @MainActor in
                FieldPreferencesManager.shared.saveStockFieldPreferences(newValue)
            }
            
            // Keep UserDefaults for backwards compatibility (immediate)
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: StockKeys.stockFieldPreferences)
            }
        }
    }
    
    private func loadStockFieldPreferencesSync() -> StockFieldPreferences? {
        // Access SwiftData synchronously from main thread if available
        guard Thread.isMainThread else {
            return nil
        }
        
        // Use MainActor.assumeIsolated to safely access the main actor context
        return MainActor.assumeIsolated {
            guard let context = FieldPreferencesManager.shared.modelContext else {
                return nil
            }
            
            let descriptor = FetchDescriptor<StockFieldPreferencesModel>(
                predicate: #Predicate { $0.id == "default" }
            )
            
            do {
                let models = try context.fetch(descriptor)
                guard let model = models.first else { return nil }
                
                return try JSONDecoder().decode(StockFieldPreferences.self, from: model.fieldItemsData)
            } catch {
                print("[UserDefaults] Error loading stock preferences from SwiftData: \(error)")
                return nil
            }
        }
    }
    
    /// Temporary method to force reset stock field preferences (for debugging)
    func resetStockFieldPreferences() {
        removeObject(forKey: "stockFieldPreferences")
        // Also clear SwiftData
        Task { @MainActor in
            if let context = FieldPreferencesManager.shared.modelContext {
                let descriptor = FetchDescriptor<StockFieldPreferencesModel>()
                do {
                    let models = try context.fetch(descriptor)
                    for model in models {
                        context.delete(model)
                    }
                    try context.save()
                } catch {
                    print("[DEBUG] Error clearing SwiftData: \(error)")
                }
            }
        }
        print("[DEBUG] Stock preferences reset - will use fresh defaults")
    }
}
