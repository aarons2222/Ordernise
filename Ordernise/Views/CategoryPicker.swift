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
    
    // Create a "None" category for the dropdown
    private var noneCategory: Category {
        Category(name: "None", colorHex: "#808080") // Gray color in hex
    }
    
    // All options including None
    private var allOptions: [Category] {
        [noneCategory] + categories
    }
    
    // Current selection (convert nil to noneCategory)
    private var currentSelection: Category {
        selection ?? noneCategory
    }
    
    var body: some View {
        CustomDropdownMenu(
            title: "Category",
            options: allOptions,
            selection: Binding<Category>(
                get: { currentSelection },
                set: { newValue in
                    // If "None" is selected, set selection to nil
                    if newValue.name == "None" {
                        selection = nil
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
