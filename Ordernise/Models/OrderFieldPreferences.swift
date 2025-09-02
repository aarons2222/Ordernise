//
//  OrderFieldPreferences.swift
//  Ordernise
//
//  Created by Aaron Strickland on 07/08/2025.
//

import Foundation
import SwiftData


struct CustomOrderField: Codable, Equatable, Identifiable {
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
enum BuiltInOrderField: String, Codable, CaseIterable {
    case orderDate = "orderDate"
    case orderReference = "orderReference"
    case customerName = "customerName"
    case orderStatus = "orderStatus"
    case platform = "platform"
    case shipping = "shipping"
    case orderCompletionDate = "orderCompletionDate"
    case sellingFees = "sellingFees"
    case additionalCosts = "additionalCosts"

    case notes = "notes"
    case itemsSection = "itemsSection"
    
    var displayName: String {
        switch self {
        case .orderDate: return String(localized: "Order Date")
        case .orderReference: return String(localized: "Order Reference")
        case .customerName: return String(localized: "Customer Name")
        case .orderStatus: return  String(localized: "Order Status")
        case .platform: return String(localized: "Platform")
        case .shipping: return String(localized: "Shipping")
        case .orderCompletionDate: return String(localized: "Order Completion Date")
        case .sellingFees: return String(localized: "Selling Fees")
        case .additionalCosts: return String(localized: "Additional Costs")

            
            
        case .notes: return String(localized: "Notes")
        case .itemsSection: return String(localized: "Items")
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .orderDate, .orderStatus, .itemsSection:
            return true
        default:
            return false
        }
    }
    
    var systemImage: String {
        switch self {
        case .orderDate: return "calendar"
        case .orderReference: return "number"
        case .customerName: return "person"
        case .orderStatus: return "checklist"
        case .platform: return "square.stack.3d.down.forward"
        case .shipping: return "truck.box.badge.clock"
        case .orderCompletionDate: return "calendar.badge.clock"
        case .sellingFees, .additionalCosts: return "dollarsign.circle"
        case .notes: return "text.alignleft"
        case .itemsSection: return "list.bullet.rectangle"
        }
    }
}

struct OrderFieldItem: Codable, Equatable, Identifiable {
    var isBuiltIn: Bool
    var builtInField: BuiltInOrderField?
    var customField: CustomOrderField?
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
    
    init(builtInField: BuiltInOrderField, isVisible: Bool = true, sortOrder: Int = 0) {
        self.isBuiltIn = true
        self.builtInField = builtInField
        self.customField = nil
        self.isVisible = isVisible
        self.sortOrder = sortOrder
    }
    
    init(customField: CustomOrderField, isVisible: Bool = true, sortOrder: Int = 0) {
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

struct OrderFieldPreferences: Codable, Equatable {
    // Field ordering and visibility
    var fieldItems: [OrderFieldItem] = []
    

    
    static let `default` = OrderFieldPreferences()
    
    // Initialize with default field configuration for new app
    init() {
        initializeDefaultFields()
    }
    
    // Predefined configurations for common use cases
    static let minimal = OrderFieldPreferences(preset: .minimal)
    static let shipping = OrderFieldPreferences(preset: .shipping)
    static let marketplace = OrderFieldPreferences(preset: .marketplace)
    
    private init(preset: Preset) {
        initializeDefaultFields()
//applyPreset(preset)
    }
    
    private enum Preset {
        case minimal, shipping, marketplace
    }
    
    // MARK: - Helper Methods
    
    /// Initialize with default field configuration
    private mutating func initializeDefaultFields() {
        fieldItems = [
            OrderFieldItem(builtInField: .orderDate, isVisible: true, sortOrder: 0),
            OrderFieldItem(builtInField: .orderReference, isVisible: true, sortOrder: 1),
            OrderFieldItem(builtInField: .customerName, isVisible: true, sortOrder: 2),
            OrderFieldItem(builtInField: .orderStatus, isVisible: true, sortOrder: 3),
            OrderFieldItem(builtInField: .itemsSection, isVisible: true, sortOrder: 4),
            OrderFieldItem(builtInField: .platform, isVisible: true, sortOrder: 5),
            OrderFieldItem(builtInField: .shipping, isVisible: true, sortOrder: 6),
            OrderFieldItem(builtInField: .sellingFees, isVisible: true, sortOrder: 7),
            OrderFieldItem(builtInField: .additionalCosts, isVisible: true, sortOrder: 8),
            OrderFieldItem(builtInField: .orderCompletionDate, isVisible: true, sortOrder: 9),
            OrderFieldItem(builtInField: .notes, isVisible: true, sortOrder: 10)
           
        ]
    }
    

    /// Helper to set field visibility
    private mutating func setFieldVisibility(_ field: BuiltInOrderField, visible: Bool) {
        if let index = fieldItems.firstIndex(where: { $0.builtInField == field }) {
            fieldItems[index].isVisible = visible
        }
    }
    

    
    /// Adds a new custom field
    mutating func addCustomField(_ field: CustomOrderField) {
        let newItem = OrderFieldItem(
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
    var visibleFields: [OrderFieldItem] {
        return fieldItems
            .filter { $0.isVisible }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Gets all fields in sort order
    var allFieldsInOrder: [OrderFieldItem] {
        print("[DEBUG COMPUTED] fieldItems.count: \(fieldItems.count)")
        for item in fieldItems {
            if let builtIn = item.builtInField {
                print("[DEBUG COMPUTED] fieldItem: \(builtIn.rawValue) - sortOrder: \(item.sortOrder)")
            }
        }
        
        let sorted = fieldItems.sorted { $0.sortOrder < $1.sortOrder }
        print("[DEBUG COMPUTED] sorted.count: \(sorted.count)")
        return sorted
    }
    

}

// MARK: - UserDefaults Extension (SwiftData-backed)
extension UserDefaults {
    private enum Keys {
        static let orderFieldPreferences = "orderFieldPreferences"
    }
    
    var orderFieldPreferences: OrderFieldPreferences {
        get {
            // Try SwiftData first (synchronously)
            if let swiftDataPrefs = loadOrderFieldPreferencesSync() {
                return swiftDataPrefs
            }
            
            // Fallback to UserDefaults and migrate
            guard let data = data(forKey: Keys.orderFieldPreferences),
                  let preferences = try? JSONDecoder().decode(OrderFieldPreferences.self, from: data) else {
                return OrderFieldPreferences.default
            }
            
            // Migrate to SwiftData asynchronously
            Task { @MainActor in
                FieldPreferencesManager.shared.saveOrderFieldPreferences(preferences)
                print("[UserDefaults] Migrated order preferences to SwiftData")
            }
            
            return preferences
        }
        set {
            // Save to SwiftData (primary) asynchronously
            Task { @MainActor in
                FieldPreferencesManager.shared.saveOrderFieldPreferences(newValue)
            }
            
            // Keep UserDefaults for backwards compatibility (immediate)
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: Keys.orderFieldPreferences)
            }
        }
    }
    
    private func loadOrderFieldPreferencesSync() -> OrderFieldPreferences? {
        // Access SwiftData synchronously from main thread if available
        guard Thread.isMainThread else {
            return nil
        }
        
        // Use MainActor.assumeIsolated to safely access the main actor context
        return MainActor.assumeIsolated {
            guard let context = FieldPreferencesManager.shared.modelContext else {
                return nil
            }
            
            let descriptor = FetchDescriptor<OrderFieldPreferencesModel>(
                predicate: #Predicate { $0.id == "default" }
            )
            
            do {
                let models = try context.fetch(descriptor)
                guard let model = models.first else { return nil }
                
                return try JSONDecoder().decode(OrderFieldPreferences.self, from: model.fieldItemsData)
            } catch {
                print("[UserDefaults] Error loading order preferences from SwiftData: \(error)")
                return nil
            }
        }
    }
    
    /// Temporary method to force reset field preferences (for debugging)
    func resetOrderFieldPreferences() {
        removeObject(forKey: "orderFieldPreferences")
        // Also clear SwiftData
        Task { @MainActor in
            if let context = FieldPreferencesManager.shared.modelContext {
                let descriptor = FetchDescriptor<OrderFieldPreferencesModel>()
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
        print("[DEBUG] Preferences reset - will use fresh defaults")
    }
}
