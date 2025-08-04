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
    var attributeTemplates: [AttributeTemplate] {
        do {
            let descriptor = FetchDescriptor<AttributeTemplate>()
            let allTemplates = try modelContext.fetch(descriptor)
            return allTemplates.filter { $0.templateType == .stockItem }
        } catch {
            print("Failed to fetch templates: \(error)")
            return []
        }
    }
    
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
    
    
    @State private var name = ""
    @State private var quantity = 0
    @State private var price = 0.0
    @State private var cost = 0.0
    @State private var selectedCategory: Category?
    
    // Dynamic attributes storage
    @State private var attributes: [AttributeField] = []
    @State private var isEditMode = false
    
    // Template management
    @State private var showingTemplateSheet = false
    @State private var showingSaveTemplateAlert = false
    @State private var templateName = ""
    
    // Standalone attribute sheet
    @State private var showingAttributeSheet = false
    @State private var newAttributeKey = ""
    @State private var newAttributeValue = ""
    @State private var editingAttribute: AttributeField?
    @State private var isEditingAttribute = false
    @FocusState private var attributeKeyboardFocused: Bool
    
    // Navigation to CategoryOptions
    @State private var showingCategoryOptions = false
    
    // Use the same AttributeField type as other views
    typealias AttributeField = OrderDetailView.AttributeField
    
    // Initializer for adding new item
    init(mode: Mode = .add) {
        self.mode = mode
        self.stockItem = nil
    }
    
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
            
                     
                        
                        ListSection(title: "Item Name") {
                            
                            CustomTextField(
                                text: $name,
                                placeholder: "Enter item name",
                                systemImage: "person",
                                isSecure: false
                            )
                        }
                        .padding(.horizontal, 20)
                  
                 
                        
                        
                        
                        HStack{
                            
                            Text("Quantity")
                                .font(.caption)
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
                        .padding(.horizontal, 20)
                        
                        
                        
                        
                        
                        
                
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Category")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                               
                                    if categories.isEmpty {
                                      
                                        
                                        
                                        GlobalButton(title: "Create Categories", showIcon: true, icon: "plus.circle" ,  action: {
                                            showingCategoryOptions = true
                                        })
                                    
                                        
                                        
                                        
                                        
                                        
                                        
                                    } else {
                                        // Use the new CategoryPicker component
                                        CategoryPicker(
                                            selection: $selectedCategory,
                                            categories: categories
                                        )
                                   
                                    }
                                
                            }.padding(.horizontal, 15)
                        
                  
                   
                    

                        
                        
                        
                        ListSection(title: "Item Price") {
                            
                            
                            CustomNumberField(
                                value: $price,
                                placeholder: "Item Price",
                                systemImage: localeManager.currencySymbolName,
                                format: localeManager.currencyFormatStyle
                            )
                            
                            
                        }.padding(.horizontal, 20)
                        
                        
                        
                        ListSection(title: "Item Cost") {
                            
                            CustomNumberField(
                                value: $cost,
                                placeholder: "Item Cost",
                                systemImage: localeManager.currencySymbolName,
                                format: localeManager.currencyFormatStyle
                            )
                            
                        }.padding(.horizontal, 20)

                        
                        
                        
                    
                        
                     
                        
                    
                    
   
                            
                            ListSection(title: "Custom Attributes") {
                            // Display existing attributes
                            ForEach(attributes) { attribute in
                                HStack {
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(attribute.key)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(attribute.value)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if mode.isEditable || isEditMode {
                                        Button(action: {
                                            removeAttribute(attribute)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                       
                                Button(action: { showingAttributeSheet = true }) {
                                    Label("Add Attribute", systemImage: "plus.circle")
                                }
                                
                                if !attributeTemplates.isEmpty {
                                    Button(action: { showingTemplateSheet = true }) {
                                        Label("Load Template", systemImage: "tray.and.arrow.down")
                                    }
                                }
                                
                                if !attributes.isEmpty && attributes.contains(where: { !$0.key.isEmpty }) {
                                    Button(action: { showingSaveTemplateAlert = true }) {
                                        Label("Save as Template", systemImage: "tray.and.arrow.up")
                                    }
                                }
                            
                        }
                        .padding(.horizontal, 20)
                    
                }
              
            }
        }
        .onAppear {
            loadItemData()
        }
        
        .fullScreenCover(isPresented: $showingTemplateSheet) {
            
            AttributeTemplatePickerView(
                templates: attributeTemplates,
                onTemplateSelected: loadTemplate
            )
        }
        
        
        
        
        
        .sheet(isPresented: $showingAttributeSheet) {
            NavigationStack {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isEditingAttribute ? "Edit Attribute" : "Add Attribute")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(isEditingAttribute ? "Update the attribute information" : "Add custom information to this item")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Attribute Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            CustomTextField(
                                text: $newAttributeKey,
                                placeholder: "e.g., Color, Size, Material",
                                systemImage: "tag",
                                isSecure: false
                            )
                            .focused($attributeKeyboardFocused)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Value")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            CustomTextField(
                                text: $newAttributeValue,
                                placeholder: "Enter the value for this attribute",
                                systemImage: "textformat",
                                isSecure: false
                            )
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            dismissAttributeSheet()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.5).gradient)
                        .foregroundColor(.primary)
                        .cornerRadius(40)
                        
                        Button(isEditingAttribute ? "Save Changes" : "Add Attribute") {
                            saveAttribute()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.appTint.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(40)
                        .disabled(newAttributeKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newAttributeValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(24)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
                .onAppear {
                    if isEditingAttribute, let editingAttribute = editingAttribute {
                        newAttributeKey = editingAttribute.key
                        newAttributeValue = editingAttribute.value
                    }
                    attributeKeyboardFocused = true
                }
            }
        }
        .sheet(isPresented: $showingCategoryOptions) {
            CategoryOptions()
        }
        .alert("Save Template", isPresented: $showingSaveTemplateAlert) {
            TextField("Template Name", text: $templateName)
            Button("Save") {
                saveAsTemplate()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for this attribute template")
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
            
            // Load attributes
            attributes = item.attributes.map { key, value in
                AttributeField(key: key, value: value)
            }
        } else {
            // For new items, currency is already managed by LocaleManager
            // Load default template if available
            loadDefaultTemplate()
        }
    }
    
//    private func addAttribute() {
//        attributes.append(AttributeField())
//    }
//    
    private func removeAttribute(_ attribute: AttributeField) {
        attributes.removeAll { $0.id == attribute.id }
    }
    
    private func saveAttribute() {
        let trimmedKey = newAttributeKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = newAttributeValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKey.isEmpty && !trimmedValue.isEmpty else { return }
        
        if isEditingAttribute, let editingAttribute = editingAttribute {
            // Update existing attribute
            if let index = attributes.firstIndex(where: { $0.id == editingAttribute.id }) {
                attributes[index].key = trimmedKey
                attributes[index].value = trimmedValue
            }
        } else {
            // Add new attribute
            let newAttribute = AttributeField(key: trimmedKey, value: trimmedValue)
            attributes.append(newAttribute)
        }
        
        dismissAttributeSheet()
    }
    
    private func dismissAttributeSheet() {
        showingAttributeSheet = false
        newAttributeKey = ""
        newAttributeValue = ""
        editingAttribute = nil
        isEditingAttribute = false
    }
    

    private func loadDefaultTemplate() {
        // Find the default template for stock items
        if let defaultTemplate = attributeTemplates.first(where: { $0.isDefault }) {
            attributes = defaultTemplate.attributes.map { key, value in
                AttributeField(key: key, value: value)
            }
        }
    }
    
    private func loadTemplate(_ template: AttributeTemplate) {
        // Replace current attributes with template attributes
        attributes = template.attributes.map { key, value in
            AttributeField(key: key, value: value)
        }
        showingTemplateSheet = false
    }
    
    private func saveAsTemplate() {
        guard !templateName.isEmpty else { return }
        
        let attributesDict = Dictionary(
            uniqueKeysWithValues: attributes
                .filter { !$0.key.isEmpty }
                .map { ($0.key, $0.value) }
        )
        
        let template = AttributeTemplate(
            name: templateName,
            attributes: attributesDict,
            templateType: .stockItem
        )
        
        modelContext.insert(template)
        
        do {
            try modelContext.save()
            templateName = ""
        } catch {
            print("Failed to save template: \(error)")
        }
    }
    
    private func saveItem() {
        let attributesDict = Dictionary(
            uniqueKeysWithValues: attributes
                .filter { !$0.key.isEmpty }
                .map { ($0.key, $0.value) }
        )
        
        if let existingItem = stockItem {
            // Edit existing item
            existingItem.name = name
            existingItem.quantityAvailable = quantity
            existingItem.price = price
            existingItem.cost = cost
            existingItem.currency = localeManager.currentCurrency
            existingItem.category = selectedCategory
            existingItem.attributes = attributesDict
        } else {
            // Add new item
            let newItem = StockItem(
                name: name,
                quantityAvailable: quantity,
                price: price,
                cost: cost,
                currency: localeManager.currentCurrency,
                attributes: attributesDict
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
