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
    @Query(sort: \Category.name) private var categories: [Category]
    
    // Using direct fetch instead of @Query to avoid SwiftData macro issues

    
    enum Mode {
        case add
        case edit
        case view
        
        var title: String {
            switch self {
            case .add: return "Add Stock Item"
            case .edit: return "Edit Stock Item"
            case .view: return "Stock Item"
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
    @State private var showingStockFieldSettings = false
    
    // Custom field values storage
    @State private var customFieldValues: [String: String] = [:]
    
    // Navigation to CategoryOptions
    @State private var showingCategoryOptions = false
    
    // Field preferences for dynamic field rendering
    @State private var fieldPreferences = UserDefaults.standard.stockFieldPreferences
    

    
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
                    buttonContent: "Save",
                    isButtonImage: false,
                    showTrailingButton: true,
                    showLeadingButton: true,
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
                ListSection(title: "Item Name") {
                    CustomTextField(
                        text: $name,
                        placeholder: "Enter item name",
                        systemImage: "tag",
                        isSecure: false
                    )
                }
                .padding(.horizontal, 20)
                
            case .quantityAvailable:
                CustomCardView {
                    HStack {
                        Text("Quantity")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
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
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
                
            case .category:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if categories.isEmpty {
                        GlobalButton(title: "Create Categories", showIcon: true, icon: "plus.circle") {
                            showingCategoryOptions = true
                        }
                    } else {
                        CategoryPicker(
                            selection: $selectedCategory,
                            categories: categories,
                            onManageCategories: {
                                showingCategoryOptions = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 15)
                
            case .price:
                ListSection(title: "Item Price") {
                    CustomNumberField(
                        value: $price,
                        placeholder: "Item Price",
                        systemImage: localeManager.currencySymbolName,
                        format: localeManager.currencyFormatStyle
                    )
                }
                .padding(.horizontal, 20)
                
            case .cost:
                ListSection(title: "Item Cost") {
                    CustomNumberField(
                        value: $cost,
                        placeholder: "Item Cost",
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
        switch field.fieldType {
        case .text:
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
            
        case .number:
            ListSection(title: field.name) {
                CustomNumberField(
                    value: Binding(
                        get: { Double(customFieldValues[field.id.uuidString] ?? "0") ?? 0.0 },
                        set: { customFieldValues[field.id.uuidString] = String($0) }
                    ),
                    placeholder: field.placeholder,
                    systemImage: "number",
                    format: .currency(code: localeManager.currentCurrency.rawValue).precision(.fractionLength(2))
                )
            }
            .padding(.horizontal, 20)
            
        case .dropdown:
            VStack(alignment: .leading, spacing: 4) {
                Text(field.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if field.dropdownOptions.isEmpty {
                    Text("No options available")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 15)
                } else {
                    Picker(field.name, selection: Binding(
                        get: { customFieldValues[field.id.uuidString] ?? "" },
                        set: { customFieldValues[field.id.uuidString] = $0 }
                    )) {
                        Text("Select \(field.name.lowercased())")
                            .tag("")
                        ForEach(field.dropdownOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 15)
                }
            }
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
        // Validation: Only for new items
        var missingFields = [String]()

        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missingFields.append("Name")
        }

        if price == 0 {
            missingFields.append("Price")
        }

        if stockItem == nil && quantity <= 0 {
            missingFields.append("Quantity")
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
            existingItem.quantityAvailable = quantity
            existingItem.price = price
            existingItem.cost = cost
            existingItem.currency = localeManager.currentCurrency
            existingItem.category = selectedCategory
            // Save custom field values to attributes
            existingItem.attributes = customFieldValues
        } else {
            // Add new item
            let newItem = StockItem(
                name: name,
                quantityAvailable: quantity,
                price: price,
                cost: cost,
                currency: localeManager.currentCurrency,
                attributes: customFieldValues
            )
            newItem.category = selectedCategory
            modelContext.insert(newItem)
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
