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
    
    let onAddCategory: (() -> Void)?
    
    // Create a "Manage Categories" option for the dropdown
    private var manageCategoriesOption: Category {
        Category(name: String(localized: "Manage Categories..."), colorHex: "#007AFF") // Blue color in hex
    }
    
    
    private var addCategoryOption: Category {
        Category(name: String(localized: "Add Category..."), colorHex: "#007AFF")
        

    }
    
    
    
    // All options including categories and action options
    private var allOptions: [Category] {
        var options = categories
        
        if let _ = onAddCategory {
            options.append(addCategoryOption)
        }
        
        if let _ = onManageCategories {
            options.append(manageCategoriesOption)
        }
        
        return options
    }
    
    // Current selection - auto-select latest (last) category if none selected
    private var currentSelection: Category {
        if let selection = selection {
            return selection
        } else if let latestCategory = categories.last {
            // Auto-select the latest (last) category if none is selected
            DispatchQueue.main.async {
                self.selection = latestCategory
            }
            return latestCategory
        } else {
            // Fallback to a placeholder category if no categories exist
            return Category(name: String(localized: "No Category"), colorHex: "#808080")
        }
    }
    
    var body: some View {
        CustomDropdownMenu(
            title: String(localized: "Category"),
            options: allOptions,
            selection: Binding<Category>(
                get: { currentSelection },
                set: { newValue in
                    if newValue.name == String(localized: "Manage Categories...") {
                        // Trigger the manage categories action
                        onManageCategories?()
                    }else if newValue.name == String(localized: "Add Category...") {
                        // Trigger the manage categories action
                        onAddCategory?()
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
