//
//  OrderFieldPreferences.swift
//  Ordernise
//
//  Created by Aaron Strickland on 07/08/2025.
//

import Foundation

// MARK: - Custom Field Types
enum OrderFieldType: String, Codable, CaseIterable {
    case text = "text"
 
 
    
    var displayName: String {
        switch self {
        case .text: return "Text Field"
        }
    }
    
    var systemImage: String {
        switch self {
        case .text: return "textformat"        }
    }
}

struct CustomOrderField: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var placeholder: String
    var fieldType: OrderFieldType
    var isRequired: Bool = false
    var isVisible: Bool = true
    var dropdownOptions: [String] = [] // For dropdown type
    
    init(name: String, placeholder: String, fieldType: OrderFieldType, isRequired: Bool = false) {
        self.name = name
        self.placeholder = placeholder
        self.fieldType = fieldType
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
    case sellingFees = "sellingFees"
    case additionalCosts = "additionalCosts"

    case notes = "notes"
    case itemsSection = "itemsSection"
    
    var displayName: String {
        switch self {
        case .orderDate: return "Order Date"
        case .orderReference: return "Order Reference"
        case .customerName: return "Customer Name"
        case .orderStatus: return "Order Status"
        case .platform: return "Platform"
        case .shipping: return "Shipping"
        case .sellingFees: return "Selling Fees"
        case .additionalCosts: return "Additional Costs"

        case .notes: return "Notes"
        case .itemsSection: return "Items"
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
            return customField?.fieldType.systemImage ?? "questionmark"
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
            OrderFieldItem(builtInField: .platform, isVisible: true, sortOrder: 4),
            OrderFieldItem(builtInField: .shipping, isVisible: true, sortOrder: 5),
            OrderFieldItem(builtInField: .sellingFees, isVisible: true, sortOrder: 6),
            OrderFieldItem(builtInField: .additionalCosts, isVisible: true, sortOrder: 7),

            OrderFieldItem(builtInField: .notes, isVisible: true, sortOrder: 8),
            OrderFieldItem(builtInField: .itemsSection, isVisible: true, sortOrder: 9)
        ]
    }
    
    /// Apply preset configuration
//    private mutating func applyPreset(_ preset: Preset) {
//        switch preset {
//        case .minimal:
//            setFieldVisibility(.shipping, visible: false)
//            setFieldVisibility(.sellingFees, visible: false)
//            setFieldVisibility(.additionalCosts, visible: false)
//            setFieldVisibility(.notes, visible: false)
//        case .shipping:
//            setFieldVisibility(.sellingFees, visible: false)
//            setFieldVisibility(.additionalCosts, visible: false)
//            setFieldVisibility(.notes, visible: false)
//        case .marketplace:
//            // All fields visible (default)
//            break
//        }
//    }
//    
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

// MARK: - UserDefaults Extension
extension UserDefaults {
    private enum Keys {
        static let orderFieldPreferences = "orderFieldPreferences"
    }
    
    var orderFieldPreferences: OrderFieldPreferences {
        get {
            guard let data = data(forKey: Keys.orderFieldPreferences),
                  let preferences = try? JSONDecoder().decode(OrderFieldPreferences.self, from: data) else {
                return OrderFieldPreferences.default
            }
            return preferences
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: Keys.orderFieldPreferences)
            }
        }
    }
    
    /// Temporary method to force reset field preferences (for debugging)
    func resetOrderFieldPreferences() {
        removeObject(forKey: "orderFieldPreferences")
        print("[DEBUG] Preferences reset - will use fresh defaults")
    }
}
