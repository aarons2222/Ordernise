//
//  OrderDetailView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct OrderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var stockItems: [StockItem]
    @Query private var orderTemplates: [OrderTemplate]
    
    enum Mode {
        case add
        case edit
        case view
        
        var title: String {
            switch self {
            case .add: return "Add Order"
            case .edit: return "Edit Order"
            case .view: return "Order Details"
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
    let order: Order?
    
    @State private var date = Date()
    @State private var customerName = ""
    @State private var status: OrderStatus = .pending
    @State private var platform: Platform = .custom
    @State private var orderItems: [OrderItemEntry] = []
    @State private var attributes: [AttributeField] = []
    @State private var isEditMode = false
    @State private var showingStockItemPicker = false
    
    // Template management
    @State private var showingTemplateSheet = false
    @State private var showingSaveTemplateAlert = false
    @State private var templateName = ""
    
    struct OrderItemEntry: Identifiable {
        let id = UUID()
        var stockItem: StockItem?
        var quantity: Int = 1
        
        var isValid: Bool {
            stockItem != nil && quantity > 0
        }
        
        var totalPrice: Double {
            guard let item = stockItem else { return 0.0 }
            return item.price * Double(quantity)
        }
    }
    
    struct AttributeField: Identifiable {
        let id = UUID()
        var key: String = ""
        var value: String = ""
    }
    
    // Initializer for adding new order
    init(mode: Mode = .add) {
        self.mode = mode
        self.order = nil
    }
    
    // Initializer for viewing/editing existing order
    init(order: Order, mode: Mode = .view) {
        self.mode = mode
        self.order = order
    }
    
    var totalOrderValue: Double {
        orderItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    // Break down complex view to help compiler
    private var orderInformationSection: some View {
        Section("Order Information") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    DatePicker("Order Date", selection: $date, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                } else {
                    Text(date, style: .date)
                        .padding(.vertical, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Customer Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    TextField("Enter customer name", text: $customerName)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(customerName.isEmpty ? "—" : customerName)
                        .padding(.vertical, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    Picker("Status", selection: $status) {
                        ForEach(OrderStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                } else {
                    HStack {
                        Circle()
                            .fill(statusColor(for: status))
                            .frame(width: 8, height: 8)
                        Text(status.rawValue.capitalized)
                            .foregroundColor(statusColor(for: status))
                    }
                    .padding(.vertical, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Platform")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    Picker("Platform", selection: $platform) {
                        ForEach(Platform.allCases, id: \.self) { platform in
                            Text(platform.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    Text(platform.rawValue)
                        .padding(.vertical, 8)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                orderInformationSection
                
                Section {
                    ForEach($orderItems) { $orderItem in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Item")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if mode.isEditable || isEditMode {
                                        Button(action: {
                                            // This would open a stock item picker
                                            showingStockItemPicker = true
                                        }) {
                                            HStack {
                                                Text(orderItem.stockItem?.name ?? "Select Item")
                                                    .foregroundColor(orderItem.stockItem == nil ? .secondary : .primary)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        Text(orderItem.stockItem?.name ?? "—")
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Quantity")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if mode.isEditable || isEditMode {
                                        TextField("Qty", value: $orderItem.quantity, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.numberPad)
                                            .frame(width: 60)
                                    } else {
                                        Text("\(orderItem.quantity)")
                                    }
                                }
                                
                                if mode.isEditable || isEditMode {
                                    Button(action: {
                                        removeOrderItem(orderItem)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            if let stockItem = orderItem.stockItem {
                                HStack {
                                    Text("Unit Price:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(stockItem.price, format: .currency(code: stockItem.currency.rawValue.uppercased()))
                                        .font(.caption)
                                    Spacer()
                                    Text("Total:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(orderItem.totalPrice, format: .currency(code: stockItem.currency.rawValue.uppercased()))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if mode.isEditable || isEditMode {
                        Button(action: addOrderItem) {
                            Label("Add Item", systemImage: "plus.circle")
                        }
                    }
                } header: {
                    HStack {
                        Text("Order Items")
                        Spacer()
                        if !orderItems.isEmpty {
                            Text("Total: \(totalOrderValue, format: .currency(code: "GBP"))")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                
                
                // Always show Custom Attributes section when editing to allow template access
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
                        
                  
                    }
                }
                
                
                if mode.isEditable || isEditMode {
                    Button(action: addAttribute) {
                        Label("Add Attribute", systemImage: "plus.circle")
                    }
                }
                
                
                // Template Management - Always visible when editing
                if mode.isEditable || isEditMode {
                    Section("Templates") {
                        Button(action: { showingTemplateSheet = true }) {
                            Label("Load Order Template (\(orderTemplates.count) available)", systemImage: "tray.and.arrow.down")
                        }
                        
                        Button(action: { showingSaveTemplateAlert = true }) {
                            Label("Save Order as Template", systemImage: "tray.and.arrow.up")
                        }
                        
                        // Debug info
                        Text("Mode: \(mode == .add ? "ADD" : mode == .edit ? "EDIT" : "VIEW")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Order Templates found: \(orderTemplates.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                            saveOrder()
                        }
                        .disabled(!isValidOrder)
                    }
                }
            }
        }
        .onAppear {
            loadOrderData()
        }
        .sheet(isPresented: $showingStockItemPicker) {
            StockItemPickerView(stockItems: stockItems) { selectedItem in
                if let lastIndex = orderItems.indices.last {
                    orderItems[lastIndex].stockItem = selectedItem
                }
            }
        }
        .sheet(isPresented: $showingTemplateSheet) {
            OrderTemplatePickerView(
                templates: orderTemplates,
                onTemplateSelected: { template in
                    loadOrderTemplate(template)
                }
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
    
    private var isValidOrder: Bool {
        !orderItems.isEmpty && orderItems.allSatisfy { $0.isValid }
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .received: return .blue
        case .pending: return .orange
        case .fulfilled: return .green
        case .canceled: return .red
        }
    }
    
    private func loadOrderData() {
        if let existingOrder = order {
            date = existingOrder.date
            customerName = existingOrder.customerName ?? ""
            status = existingOrder.status
            platform = existingOrder.platform
            
            orderItems = existingOrder.items.map { orderItem in
                OrderItemEntry(stockItem: orderItem.stockItem, quantity: orderItem.quantity)
            }
            
            // Load attributes
            attributes = existingOrder.attributes.map { key, value in
                AttributeField(key: key, value: value)
            }
        } else {
            // For new orders, start with one empty item
            addOrderItem()
            
            // Load default template if available
            loadDefaultTemplate()
        }
    }
    
    private func addOrderItem() {
        orderItems.append(OrderItemEntry())
    }
    
    private func removeOrderItem(_ orderItem: OrderItemEntry) {
        orderItems.removeAll { $0.id == orderItem.id }
    }
    
    private func addAttribute() {
        attributes.append(AttributeField())
    }
    
    private func removeAttribute(_ attribute: AttributeField) {
        attributes.removeAll { $0.id == attribute.id }
    }
    
    private func loadOrderTemplate(_ template: OrderTemplate) {
        // Load platform and status
        status = template.status
        platform = template.platform
        
        // Load custom attributes
        attributes = template.customAttributes.map { key, value in
            AttributeField(key: key, value: value)
        }
        
        // Customer name and items are NOT loaded from templates
        // Keep existing customer name as-is
        // Keep existing order items as-is
        
        print("Loaded order template: \(template.name)")
    }
    
    private func loadDefaultTemplate() {
        // Find the default order template
        if let defaultTemplate = orderTemplates.first(where: { $0.isDefault }) {
            loadOrderTemplate(defaultTemplate)
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
        
        // Create custom attributes dictionary
        let attributesDict = Dictionary(
            uniqueKeysWithValues: attributes
                .filter { !$0.key.isEmpty }
                .map { ($0.key, $0.value) }
        )
        
        // Create the order template (no customer name or items)
        let orderTemplate = OrderTemplate(
            name: templateName,
            status: status,
            platform: platform,
            customAttributes: attributesDict
        )
        
        modelContext.insert(orderTemplate)
        
        do {
            try modelContext.save()
            print("Saved order template: \(orderTemplate.name)")
            templateName = ""
        } catch {
            print("Failed to save order template: \(error)")
        }
    }
    
    private func saveOrder() {
        let validOrderItems = orderItems.filter { $0.isValid }
        
        // Create attributes dictionary from valid attributes
        let attributesDict = Dictionary(
            uniqueKeysWithValues: attributes
                .filter { !$0.key.isEmpty }
                .map { ($0.key, $0.value) }
        )
        
        if let existingOrder = order {
            // Update existing order
            existingOrder.date = date
            existingOrder.customerName = customerName.isEmpty ? nil : customerName
            existingOrder.status = status
            existingOrder.platform = platform
            existingOrder.attributes = attributesDict
            
            // Remove existing order items
            for item in existingOrder.items {
                modelContext.delete(item)
            }
            
            // Add new order items
            for orderItemEntry in validOrderItems {
                let orderItem = OrderItem(quantity: orderItemEntry.quantity, stockItem: orderItemEntry.stockItem)
                orderItem.order = existingOrder
            }
        } else {
            // Create new order
            let newOrder = Order(
                date: date,
                customerName: customerName.isEmpty ? nil : customerName,
                status: status,
                platform: platform,
                attributes: attributesDict
            )
            
            // Add order items
            for orderItemEntry in validOrderItems {
                let orderItem = OrderItem(quantity: orderItemEntry.quantity, stockItem: orderItemEntry.stockItem)
                orderItem.order = newOrder
                newOrder.items.append(orderItem)
            }
            
            modelContext.insert(newOrder)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save order: \(error)")
        }
    }
}

// Helper view for selecting stock items
struct StockItemPickerView: View {
    let stockItems: [StockItem]
    let onSelection: (StockItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(stockItems) { item in
                Button(action: {
                    onSelection(item)
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .foregroundColor(.primary)
                        HStack {
                            Text("Qty: \(item.quantityAvailable)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(item.price, format: .currency(code: item.currency.rawValue.uppercased()))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Select Stock Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    OrderDetailView(mode: .add)
}
