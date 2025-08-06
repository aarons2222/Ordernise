import SwiftUI

// Re-use the AttributeField from OrderDetailView
typealias AttributeField = OrderDetailView.AttributeField

struct OrderItemPickerView: View {
    let stockItems: [StockItem]
    let existingQuantities: [StockItem.ID: Int]
    let existingAttributes: [StockItem.ID: [AttributeField]]
    let onSelection: (StockItem, Int, [AttributeField]) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localeManager = LocaleManager.shared
    @State private var quantities: [StockItem.ID: Int] = [:]
    @State private var itemAttributes: [StockItem.ID: [AttributeField]] = [:]
    
    // Bottom sheet state variables
    @State private var showingAddAttributeSheet = false
    @State private var newAttributeKey = ""
    @State private var newAttributeValue = ""
    @FocusState private var keyboardFocused: Bool
    @State private var editingAttribute: AttributeField?
    @State private var currentItem: StockItem?
    @State private var isEditingAttribute = false
    
    private func getQuantity(for item: StockItem) -> Int {
        quantities[item.id] ?? 0
    }
    
    private func setQuantity(for item: StockItem, quantity: Int) {
        let maxAllowed = item.quantityAvailable
        let clamped = min(max(0, quantity), maxAllowed)
        quantities[item.id] = clamped
    }
    
    private func canIncrement(for item: StockItem) -> Bool {
        let currentQuantity = getQuantity(for: item)
        return currentQuantity < item.quantityAvailable
    }
    
    private func canDecrement(for item: StockItem) -> Bool {
        return getQuantity(for: item) > 0
    }
    
    private func getAttributes(for item: StockItem) -> [AttributeField] {
        return itemAttributes[item.id] ?? []
    }
    
    private func setAttributes(for item: StockItem, attributes: [AttributeField]) {
        // Create new dictionary to trigger SwiftUI state update
        var newAttributes = itemAttributes
        newAttributes[item.id] = attributes
        itemAttributes = newAttributes
        print("🔄 setAttributes: Updated itemAttributes for \(item.name) with \(attributes.count) attributes")
    }
    
    private func addAttribute(for item: StockItem) {
        currentItem = item
        isEditingAttribute = false
        editingAttribute = nil
        newAttributeKey = ""
        newAttributeValue = ""
        showingAddAttributeSheet = true
    }
    
    private func editAttribute(for item: StockItem, attribute: AttributeField) {
        currentItem = item
        isEditingAttribute = true
        editingAttribute = attribute
        newAttributeKey = attribute.key
        newAttributeValue = attribute.value
        showingAddAttributeSheet = true
    }
    
    private func saveNewAttribute() {
        guard let item = currentItem else { 
            print("❌ No current item selected")
            return 
        }
        
        let trimmedKey = newAttributeKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = newAttributeValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKey.isEmpty && !trimmedValue.isEmpty else { 
            print("❌ Empty key or value: key='\(trimmedKey)', value='\(trimmedValue)'")
            return 
        }
        
        print("✅ Saving attribute: \(trimmedKey) = \(trimmedValue) for item: \(item.name)")
        
        var currentAttributes = getAttributes(for: item)
        print("📋 Current attributes count: \(currentAttributes.count)")
        
        if isEditingAttribute, let editingAttribute = editingAttribute {
            // Update existing attribute
            if let index = currentAttributes.firstIndex(where: { $0.id == editingAttribute.id }) {
                currentAttributes[index].key = trimmedKey
                currentAttributes[index].value = trimmedValue
                print("✏️ Updated attribute at index \(index)")
            }
        } else {
            // Add new attribute
            let newAttribute = AttributeField(key: trimmedKey, value: trimmedValue)
            currentAttributes.append(newAttribute)
            print("➕ Added new attribute. Total count: \(currentAttributes.count)")
        }
        
        setAttributes(for: item, attributes: currentAttributes)
        print("💾 Attributes saved for item \(item.id). New count: \(getAttributes(for: item).count)")
        
        // Trigger callback to notify OrderDetailView of attribute changes
        let currentQuantity = getQuantity(for: item)
        onSelection(item, currentQuantity, currentAttributes)
        print("📞 Triggered callback for \(item.name) with \(currentAttributes.count) attributes")
        
        // Clear form
        showingAddAttributeSheet = false
        newAttributeKey = ""
        newAttributeValue = ""
        editingAttribute = nil
        currentItem = nil
        isEditingAttribute = false
    }
    
    private func removeAttribute(for item: StockItem, attribute: AttributeField) {
        var currentAttributes = getAttributes(for: item)
        currentAttributes.removeAll { $0.id == attribute.id }
        setAttributes(for: item, attributes: currentAttributes)
        
        print("🗑️ Removed attribute: \(attribute.key) for item: \(item.name)")
        print("📋 Remaining attributes: \(currentAttributes.count)")
        
        // Trigger callback to notify OrderDetailView of attribute changes
        let currentQuantity = getQuantity(for: item)
        onSelection(item, currentQuantity, currentAttributes)
        print("📞 Triggered callback after removing attribute from \(item.name)")
    }
    
    private func removeAttributeOverride(for item: StockItem, key: String) {
        var currentAttributes = getAttributes(for: item)
        currentAttributes.removeAll { $0.key == key }
        setAttributes(for: item, attributes: currentAttributes)
        
        print("🔄 Removed override for \(key), reverting to base value for item: \(item.name)")
    }
    
    private func overrideBaseAttribute(for item: StockItem, key: String, defaultValue: String) {
        currentItem = item
        isEditingAttribute = false
        editingAttribute = nil
        newAttributeKey = key
        newAttributeValue = defaultValue
        showingAddAttributeSheet = true
        
        print("🎯 Setting up override for \(key) with default value: \(defaultValue)")
    }
    

    
    private var hasSelectedItems: Bool {
        quantities.values.contains { $0 > 0 }
    }
    
    private func addSelectedItems() {
        for item in stockItems {
            let quantity = getQuantity(for: item)
            let originalQuantity = existingQuantities[item.id] ?? 0
            let attributes = getAttributes(for: item)
            
            // Call callback if quantity has changed from original OR if item has attributes
            if quantity != originalQuantity || !attributes.isEmpty {
                onSelection(item, quantity, attributes)
                print("📤 addSelectedItems: Called callback for \(item.name) - qty: \(quantity), attrs: \(attributes.count)")
            }
        }
        dismiss()
    }
    
    private func initializeQuantities() {
        print("🔄 StockItemPickerView: initializeQuantities() called")
        print("📦 existingQuantities: \(existingQuantities)")
        print("📝 existingAttributes: \(existingAttributes)")
        
        // First, set all items to 0
        for item in stockItems {
            quantities[item.id] = 0
        }
        
        // Then, set quantities from existing order
        for (stockItemId, quantity) in existingQuantities {
            quantities[stockItemId] = quantity
        }
        
        // Initialize attributes from existing order items
        for (stockItemId, attributes) in existingAttributes {
            itemAttributes[stockItemId] = attributes
            print("🔧 Setting attributes for item \(stockItemId): \(attributes.count) attributes")
        }
        
        print("✅ Final itemAttributes state: \(itemAttributes)")
    }
    
    var body: some View {
        VStack {
            
            
            
            HeaderWithButton(
                title: "Add Items",
                buttonContent: "Save",
                isButtonImage: false,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    addSelectedItems()
                    
                }
            )
            
            
            ScrollView{
                
                VStack{
            
            
                    ForEach(stockItems) { item in
                        
                        CustomCardView{
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    HStack {
                                        Text("Available: \(item.quantityAvailable - getQuantity(for: item))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        
                                        Text(item.price, format: localeManager.currencyFormatStyle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    // Decrement Button
                                    Button {
                                        let currentQty = getQuantity(for: item)
                                        setQuantity(for: item, quantity: currentQty - 1)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(canDecrement(for: item) ? Color.appTint.opacity(0.8) : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(!canDecrement(for: item))
                                    
                                    Text("\(getQuantity(for: item))")
                                        .font(.headline)
                                        .frame(minWidth: 30)
                                    
                                    // Increment Button
                                    Button {
                                        let currentQty = getQuantity(for: item)
                                        setQuantity(for: item, quantity: currentQty + 1)
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(canIncrement(for: item) ? Color.appTint : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(!canIncrement(for: item))
                                }
                            }
                            
                            if getQuantity(for: item) > 0 {
                                HStack {
                                    Text("Total: ")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text((item.price * Double(getQuantity(for: item))), format: localeManager.currencyFormatStyle)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                
                                // Attributes section
                                VStack(alignment: .leading, spacing: 8) {
                                    // Show stock item base attributes (can be overridden for this order)
                                    ForEach(Array(item.attributes.keys.sorted()), id: \.self) { key in
                                        if let defaultValue = item.attributes[key] {
                                            let currentAttributes = getAttributes(for: item)
                                            let isOverridden = currentAttributes.contains { $0.key == key }
                                            let displayValue = currentAttributes.first { $0.key == key }?.value ?? defaultValue
                                            
                                            HStack {
                                                Image(systemName: isOverridden ? "tag.fill" : "tag")
                                                    .foregroundColor(isOverridden ? Color.appTint : .secondary)
                                                    .font(.title2)
                                                Text("\(key): \(displayValue)")
                                                    .font(.title2)
                                                    .foregroundColor(isOverridden ? .primary : .secondary)
                                                Spacer()
                                                
                                                if isOverridden {
                                                    // Show "Overridden" badge and allow removing override
                                                    Button {
                                                        removeAttributeOverride(for: item, key: key)
                                                    } label: {
                                                        HStack(spacing: 4) {
                                                            Text("Override")
                                                                .font(.caption)
                                                                .foregroundColor(.white)
                                                            Image(systemName: "xmark")
                                                                .font(.caption)
                                                                .foregroundColor(.white)
                                                        }
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Color.appTint)
                                                        .cornerRadius(4)
                                                    }
                                                    .buttonStyle(.plain)
                                                } else {
                                                    // Show "Base" badge and allow overriding
                                                    Button {
                                                        overrideBaseAttribute(for: item, key: key, defaultValue: defaultValue)
                                                    } label: {
                                                        Text("Edit")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.secondary.opacity(0.1))
                                                            .cornerRadius(4)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            .padding(.vertical, 2)
                                            .onTapGesture {
                                                if isOverridden {
                                                    // Edit the overridden value
                                                    if let attribute = currentAttributes.first(where: { $0.key == key }) {
                                                        editAttribute(for: item, attribute: attribute)
                                                    }
                                                } else {
                                                    // Create override
                                                    overrideBaseAttribute(for: item, key: key, defaultValue: defaultValue)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Show order-specific attributes (editable)
                                    let currentAttributes = getAttributes(for: item)
                                    let _ = print("📄 UI: Displaying \(currentAttributes.count) order attributes for \(item.name)")
                                    ForEach(currentAttributes) { attribute in
                                        HStack {
                                            Image(systemName: "tag.fill")
                                                .foregroundColor(Color.appTint)
                                                .font(.title2)
                                            Text("\(attribute.key): \(attribute.value)")
                                                .font(.title2)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Button {
                                                removeAttribute(for: item, attribute: attribute)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red.opacity(0.6))
                                                    .font(.title2)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .padding(.vertical, 2)
                                        .onTapGesture {
                                            editAttribute(for: item, attribute: attribute)
                                        }
                                    }
                                    
                                    // Add attribute button
                                    Button {
                                        addAttribute(for: item)
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(Color.appTint)
                                                .font(.title2)
                                            Text("Add Attribute")
                                                .font(.title2)
                                                .foregroundColor(Color.appTint)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                        
                    }
            }
            
        }
                .padding(.horizontal, 20)
    }
            
            .navigationBarBackButtonHidden()
//            .navigationTitle("Select Stock Items")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        addSelectedItems()
//                    }
//               
//                }
//            }
        }
        .onAppear {
            initializeQuantities()
        }
        .sheet(isPresented: $showingAddAttributeSheet) {
            NavigationStack {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isEditingAttribute ? "Edit Attribute" : "Add Attribute")
                            .font(.title)
                        
                        
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
                                systemImage: "person",
                                isSecure: false
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Value")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            CustomTextField(
                                text: $newAttributeValue,
                                placeholder: "Enter the value for this attribute",
                                systemImage: "person",
                                isSecure: false
                            )
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            showingAddAttributeSheet = false
                            newAttributeKey = ""
                            newAttributeValue = ""
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.5).gradient)
                        .foregroundColor(.primary)
                        .cornerRadius(40)
                        
                        Button(isEditingAttribute ? "Save Changes" : "Add Attribute") {
                            saveNewAttribute()
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
                }
            }
        }
    }
}
