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
    
    @State private var name = ""
    @State private var quantity = 0
    @State private var price = 0.0
    @State private var cost = 0.0
    @AppStorage("selectedCurrency") private var selectedCurrency: String = {
        let localeCurrencyID = Locale.current.currency?.identifier ?? "GBP"
        return localeCurrencyID.uppercased()
    }()
    
    @State private var currency: Currency = .gbp
    @State private var selectedCategory: Category?
    
    // Dynamic attributes storage
    @State private var attributes: [AttributeField] = []
    @State private var isEditMode = false
    
    // Template management
    @State private var showingTemplateSheet = false
    @State private var showingSaveTemplateAlert = false
    @State private var templateName = ""
    
    struct AttributeField: Identifiable {
        let id = UUID()
        var key: String = ""
        var value: String = ""
    }
    
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
            Form {
                Section("Basic Info") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if mode.isEditable || isEditMode {
                            TextField("Enter item name", text: $name)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            Text(name.isEmpty ? "—" : name)
                                .padding(.vertical, 8)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quantity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if mode.isEditable || isEditMode {
                            TextField("0", value: $quantity, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        } else {
                            Text("\(quantity)")
                                .padding(.vertical, 8)
                        }
                    }
                    
                    
                    // Only show category section if editing or if a category is set
                    if (mode.isEditable || isEditMode) || selectedCategory != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if mode.isEditable || isEditMode {
                                Menu {
                                    Button("None") {
                                        selectedCategory = nil
                                    }
                                    
                                    ForEach(categories) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            HStack {
                                                Image(systemName: "largecircle.fill.circle")
                                                    .font(.body)
                                                    .tint(category.color)
                                                
                                                Text(category.name)
                                            }
                                        }
                                        
                                        Divider()
                                    }
                                } label: {
                                    HStack {
                                        if let selectedCategory = selectedCategory {
                                            Circle()
                                                .fill(selectedCategory.color)
                                                .frame(width: 12, height: 12)
                                            Text(selectedCategory.name)
                                        } else {
                                            Text("Select Category")
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            } else {
                                if let selectedCategory = selectedCategory {
                                    HStack {
                                  
                                        
                                        Image(systemName: "largecircle.fill.circle")
                                            .font(.body)
                                            .foregroundStyle(selectedCategory.color)
                                        Text(selectedCategory.name)
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                    }
                
                
                
                Section("Pricing") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selling Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if mode.isEditable || isEditMode {
                            TextField("0.00", value: $price, format: .currency(code: currency.rawValue))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        } else {
                            Text(price, format: .currency(code: currency.rawValue))
                                .padding(.vertical, 8)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cost Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if mode.isEditable || isEditMode {
                            TextField("0.00", value: $cost, format: .currency(code: currency.rawValue))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        } else {
                            Text(cost, format: .currency(code: currency.rawValue))
                                .padding(.vertical, 8)
                        }
                    }
                    
                
                }
                
                if !attributes.isEmpty || mode.isEditable || isEditMode {
                    Section("Custom Attributes") {
                        ForEach($attributes) { $attribute in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Key")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if mode.isEditable || isEditMode {
                                        TextField("Key", text: $attribute.key)
                                            .textFieldStyle(.roundedBorder)
                                    } else {
                                        Text(attribute.key.isEmpty ? "—" : attribute.key)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Value")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if mode.isEditable || isEditMode {
                                        TextField("Value", text: $attribute.value)
                                            .textFieldStyle(.roundedBorder)
                                    } else {
                                        Text(attribute.value.isEmpty ? "—" : attribute.value)
                                    }
                                }
                                
                                if mode.isEditable || isEditMode {
                                    Button(action: {
                                        removeAttribute(attribute)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        if mode.isEditable || isEditMode {
                            Button(action: addAttribute) {
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
                    }
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if mode == .view && !isEditMode {
                        Button("Edit") {
                            isEditMode = true
                        }
                    } else if mode.isEditable || isEditMode {
                        Button("Save") {
                            saveItem()
                        }
                        .disabled(name.isEmpty)
                    }
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
            currency = item.currency
            selectedCategory = item.category
            
            // Load attributes
            attributes = item.attributes.map { key, value in
                AttributeField(key: key, value: value)
            }
        } else {
            // For new items, use the selected currency from settings
            currency = Currency(rawValue: selectedCurrency) ?? .gbp
            
            // Load default template if available
            loadDefaultTemplate()
        }
    }
    
    private func addAttribute() {
        attributes.append(AttributeField())
    }
    
    private func removeAttribute(_ attribute: AttributeField) {
        attributes.removeAll { $0.id == attribute.id }
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
            existingItem.currency = currency
            existingItem.category = selectedCategory
            existingItem.attributes = attributesDict
        } else {
            // Add new item
            let newItem = StockItem(
                name: name,
                quantityAvailable: quantity,
                price: price,
                cost: cost,
                currency: currency,
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
