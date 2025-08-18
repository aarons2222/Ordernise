//
//  StockItemDetailView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct StockItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.stockManager) private var stockManager
    @Query(sort: \Category.name) private var categories: [Category]
    
    // Using direct fetch instead of @Query to avoid SwiftData macro issues

    
    enum Mode {
        case add
        case edit
        case view
        
        var title: String {
            switch self {
            case .add: return String(localized: "Add Stock Item")
            case .edit: return String(localized: "Edit Stock Item")
            case .view: return String(localized: "Stock Item")
            }
        }
        
        var isEditable: Bool {
            switch self {
            case .add, .edit: return true
            case .view: return false
            }
        }
    }
    
   

    
    let mode: Mode
    let stockItem: StockItem?
    
    @StateObject private var localeManager = LocaleManager.shared
    
    @State var toastie: Toastie? = nil
    @State private var name = ""
    @State private var quantity = 0
    @State private var price = 0.0
    @State private var cost = 0.0
    @State private var selectedCategory: Category?
    
    @State private var isEditMode = false
    @State private var showingAddCategory = false
    @State private var showingStockFieldSettings = false
    
    // Custom field values storage
    @State private var customFieldValues: [String: String] = [:]
    
    // Navigation to CategoryOptions
    @State private var showingCategoryOptions = false
    
    
    
    @State private var newCategoryName = ""
    
    @State private var newCategoryColor = "#007AFF"
    
    
    


    
    
    // Field preferences for dynamic field rendering
    @State private var fieldPreferences = UserDefaults.standard.stockFieldPreferences
    
    // Computed property for Save button validation
    private var isSaveButtonDisabled: Bool {
        // Name is required and cannot be empty
        let hasValidName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Price is required and must be greater than 0
        let hasValidPrice = price > 0
        
        let hasValidCost = cost > 0
        
        // For new items, quantity must be greater than 0
        let hasValidQuantity = stockItem != nil || quantity > 0
        
        return !(hasValidName && hasValidPrice && hasValidQuantity && hasValidCost)
    }
    

    
    // Initializer for adding new item
    init(mode: Mode = .add) {
        self.mode = mode
        self.stockItem = nil
    }
    

    
    @State private var errorTitle = ""
    @State private var errorSubTitle = ""
    
    

    

    
    // Initializer for viewing/editing existing item
    init(stockItem: StockItem, mode: Mode = .view) {
        self.mode = mode
        self.stockItem = stockItem
    }
    
    var body: some View {
        NavigationStack {
            
            VStack{
                
                HeaderWithButton(
                    title: mode.title,
                    buttonContent: String(localized: "Save"),
                    isButtonImage: false,
                    showTrailingButton: true,
                    showLeadingButton: true,
                    isButtonDisabled: isSaveButtonDisabled,
                    onButtonTap: {
                        
                        saveItem()
                        
                    }
                )
                ScrollView {
                    // Dynamic field rendering based on user preferences
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(fieldPreferences.visibleFields) { fieldItem in
                            fieldView(for: fieldItem)
                        }
                    }
                    
                }
              
            
              
            }
             .toastieView(toast: $toastie)
             .overlay(alignment: .bottomTrailing) {
                 Button {
                     showingStockFieldSettings = true
                 } label: {
                     Image(systemName: "pencil")
                         .font(.title3)
                         .fontWeight(.semibold)
                         .foregroundStyle(.white)
                         .frame(width: 45, height: 45)
                         .background(
                             Circle()
                                 .fill(Color.appTint.gradient)
                         )
                 }
                 .padding(.trailing, 20)
                 .padding(.bottom, 10)
             }
            
   
             .GenericSheet(
                 isPresented: $showingAddCategory,
                 title: String(localized: "Add Category"),
                 showButton: false,
                 action: {
                     print("Continue tapped")
                 }
             ) {
                 
                 
                 VStack(spacing: 30){
                     
                     
                     
                     CustomTextField(text: $newCategoryName, placeholder: String(localized: "Category Name"), systemImage: "plus.square.on.square")
                         .padding(.top, 20)
                     
                     
                     CustomCardView{
                         
                         
                         HStack {
                             VStack(alignment: .leading, spacing: 8) {
                                 
                                 Text(String(localized: "Color"))
                                     .font(.headline)
                                     .foregroundColor(.text)
                                 
                                 Text(String(localized: "Pick a color to quickly recognise items in this this category"))
                                     .font(.subheadline)
                                     .foregroundColor(.secondary)
                                 
                                 
                             }
                             Spacer()
                             ColorPicker("", selection: Binding(
                                get: { Color(hex: newCategoryColor) ?? Color.appTint },
                                set: { color in
                                    newCategoryColor = color.toHex()
                                }
                             ))
                             .labelsHidden()
                         }
                     }
                     
                     
                     
                     Spacer()
                     
                     let isEmpty = newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty
                     
                     
                     
                     
                     
                     GlobalButton(title: String(localized: "Save"), backgroundColor: isEmpty ? Color.gray.opacity(0.6) : Color.appTint) {
                         saveCategory()
                     }
                     .disabled(isEmpty)
                     
                     
                 }
                 
                 
        
             }
    
        }
        .onAppear {
            loadItemData()
            fieldPreferences = UserDefaults.standard.stockFieldPreferences
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            fieldPreferences = UserDefaults.standard.stockFieldPreferences
        }
        
        .fullScreenCover(isPresented: $showingStockFieldSettings) {
            StockFieldSettings()
        }
        
        
       
        

        .sheet(isPresented: $showingCategoryOptions) {
            CategoryOptions()
        }

    }
    
    // MARK: - Dynamic Field Rendering
    @ViewBuilder
    private func fieldView(for fieldItem: StockFieldItem) -> some View {
        if fieldItem.isBuiltIn, let builtInField = fieldItem.builtInField {
            switch builtInField {
            case .name:
                ListSection(title: String(localized: "Item Name")) {
                    CustomTextField(
                        text: $name,
                        placeholder: String(localized: "Enter item name"),
                        systemImage: "tag",
                        isSecure: false
                    )
                }
                .padding(.horizontal, 20)
                
            case .quantityAvailable:
             
                VStack(alignment: .leading, spacing: 4) {
                    SectionHeader(title: String(localized: "Quantity"))
                        .padding(.leading, 0)
                    
                    HStack {
                       
                      Text(String(localized: "Quantity"))
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Decrement Button
                            Button {
                                if quantity > 0 {
                                    quantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(quantity > 0 ? Color.appTint.opacity(0.8) : .gray)
                            }
                            .buttonStyle(.plain)
                            .disabled(quantity <= 0)
                            
                            Text("\(quantity)")
                                .font(.headline)
                                .frame(minWidth: 30)
                            
                            // Increment Button
                            Button {
                                quantity += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color.appTint)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .stroke(Color.appTint, lineWidth: 2)
                    )
                }
                
                    .padding(20)
                
             
            case .category:
                VStack(alignment: .leading, spacing: 4) {
                    
                    SectionHeader(title: String(localized: "Category"))
                        .padding(.leading, 0)
                 
                    
                    if categories.isEmpty {
                        GlobalButton(title: String(localized: "Add Category"), showIcon: true, icon: "plus.circle") {
                            showingAddCategory = true
                        }
                    } else {
                        CategoryPicker(
                            selection: $selectedCategory,
                            categories: categories,
                            onManageCategories: {
                                showingCategoryOptions = true
                            },
                            onAddCategory: {
                                showingAddCategory = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 15)
                
            case .price:
                ListSection(title: String(localized: "Item Price")) {
                    CustomNumberField(
                        value: $price,
                        placeholder: String(localized: "Enter item price"),
                        systemImage: localeManager.currencySymbolName,
                        format: localeManager.currencyFormatStyle
                    )
                }
                .padding(.horizontal, 20)
                
            case .cost:
                ListSection(title: String(localized: "Item Cost")) {
                    CustomNumberField(
                        value: $cost,
                        placeholder: String(localized: "Enter item cost"),
                        systemImage: localeManager.currencySymbolName,
                        format: localeManager.currencyFormatStyle
                    )
                }
                .padding(.horizontal, 20)
            }
        } else if let customField = fieldItem.customField {
            // Render custom fields
            renderCustomField(customField)
        }
    }
    
    // MARK: - Custom Field Rendering
    @ViewBuilder
    private func renderCustomField(_ field: CustomStockField) -> some View {
     
            ListSection(title: field.name) {
                CustomTextField(
                    text: Binding(
                        get: { customFieldValues[field.id.uuidString] ?? "" },
                        set: { customFieldValues[field.id.uuidString] = $0 }
                    ),
                    placeholder: field.placeholder,
                    systemImage: "textformat"
                )
            }
            .padding(.horizontal, 20)
            
      
 
        }
    
    
    
    private func saveCategory() {
   
            // Create new category
            let category = Category(
                name: newCategoryName.trimmingCharacters(in: .whitespaces),
                colorHex: newCategoryColor
            )
            modelContext.insert(category)
      
        
        do {
            try modelContext.save()
            // Auto-select the newly created category
            selectedCategory = category
            showingAddCategory = false
            newCategoryName = ""
            newCategoryColor = "#007AFF"
        } catch {
            print("Failed to save category: \(error)")
        }
    }
    
    

    private func loadItemData() {
        // Set currency from settings for new items, or from existing item
        if let item = stockItem {
            name = item.name
            quantity = item.quantityAvailable
            price = item.price
            cost = item.cost
            selectedCategory = item.category
            
            // Load custom field values from StockItem's attributes
            customFieldValues = [:]
            
            // Load custom field values based on current preferences
            for fieldItem in fieldPreferences.fieldItems {
                if let customField = fieldItem.customField {
                    let key = customField.id.uuidString
                    // Load existing value from StockItem's attributes, or default to empty string
                    customFieldValues[key] = item.attributes[key] ?? ""
                }
            }
        } else {
            // For new items, initialize empty custom field values
            customFieldValues = [:]
            for fieldItem in fieldPreferences.fieldItems {
                if let customField = fieldItem.customField {
                    let key = customField.id.uuidString
                    customFieldValues[key] = ""
                }
            }
        }
    }
    

    
    private func saveItem() {
        // Validation checks as safety net (button should be disabled for invalid data)
        var missingFields = [String]()

        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missingFields.append("Name")
        }

        
        if stockItem == nil && quantity <= 0 {
            missingFields.append("Quantity")
        }
        
        
        if price == 0 {
            missingFields.append("Price")
        }

        
        if cost == 0 {
            missingFields.append("Cost")
        }


        if !missingFields.isEmpty {
            errorTitle = "Missing Required Fields"
            errorSubTitle = "Please fill in: \(missingFields.joined(separator: ", "))"
            
            toastie = Toastie(type: .error, title: errorTitle, message: errorSubTitle)
            return
        }

        if let existingItem = stockItem {
            // Edit existing item
            existingItem.name = name
            existingItem.price = price
            existingItem.cost = cost
            existingItem.currency = localeManager.currentCurrency
            existingItem.category = selectedCategory
            
            // Save custom field values to attributes
            existingItem.attributes = customFieldValues
            
            // Update stock quantity through StockManager (single source of truth)
            if let stockManager = stockManager {
                do {
                    try stockManager.setStockQuantity(for: existingItem, quantity: quantity)
                } catch {
                    print("❌ Failed to update stock quantity: \(error)")
                    toastie = Toastie(type: .error, title: "Error", message: "Failed to update stock quantity")
                    return
                }
            } else {
                // Fallback if StockManager not available
                existingItem.quantityAvailable = quantity
            }
            
        } else {
            // Add new item with zero initial stock - StockManager will set the actual quantity
            let newItem = StockItem(
                name: name,
                quantityAvailable: 0,
                price: price,
                cost: cost,
                currency: localeManager.currentCurrency,
                attributes: customFieldValues
            )
            newItem.category = selectedCategory
            modelContext.insert(newItem)
            
            // Set actual stock quantity through StockManager (single source of truth)
            if let stockManager = stockManager {
                do {
                    try stockManager.setStockQuantity(for: newItem, quantity: quantity)
                } catch {
                    print("❌ Failed to set stock quantity: \(error)")
                    toastie = Toastie(type: .error, title: "Error", message: "Failed to set stock quantity")
                    return
                }
            } else {
                // Fallback if StockManager not available
                newItem.quantityAvailable = quantity
            }
        }

        do {
            try modelContext.save()
            
     
                dismiss()
            
            
            
            
        
       
        } catch {
            print("Failed to save stock item: \(error)")
        }
    }
}





#Preview {
    StockItemDetailView(mode: .add)
}
