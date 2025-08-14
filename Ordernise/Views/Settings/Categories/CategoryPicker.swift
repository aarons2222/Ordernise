//
//  CategoryPicker.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//

import SwiftUI

// Custom dropdown specifically for Category selection
struct CategoryPicker: View {
    @Binding var selection: Category?
    let categories: [Category]
    let onManageCategories: (() -> Void)?
    
    // Create a "None" category for the dropdown
    private var noneCategory: Category {
        Category(name: String(localized: "None"), colorHex: "#808080") // Gray color in hex
    }
    
    // Create a "Manage Categories" option for the dropdown
    private var manageCategoriesOption: Category {
        Category(name: String(localized: "Manage Categories..."), colorHex: "#007AFF") // Blue color in hex
    }
    
    // All options including None and Manage Categories
    private var allOptions: [Category] {
        if let _ = onManageCategories {
            return [noneCategory] + categories + [manageCategoriesOption]
        } else {
            return [noneCategory] + categories
        }
    }
    
    // Current selection (convert nil to noneCategory)
    private var currentSelection: Category {
        selection ?? noneCategory
    }
    
    var body: some View {
        CustomDropdownMenu(
            title: String(localized: "Category"),
            options: allOptions,
            selection: Binding<Category>(
                get: { currentSelection },
                set: { newValue in
                    // If "None" is selected, set selection to nil
                    if newValue.name == String(localized: "None") {
                        selection = nil
                    } else if newValue.name == String(localized: "Manage Categories...") {
                        // Trigger the manage categories action
                        onManageCategories?()
                    } else {
                        selection = newValue
                    }
                }
            ),
            optionToString: { $0.name },
            optionToColor: { $0.color }
        )
    }
}
