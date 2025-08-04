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
    
    // AppStorage for remembering user preferences
    @AppStorage("lastSelectedPlatform") private var lastSelectedPlatform: String = Platform.custom.rawValue
    @AppStorage("lastCustomPlatformText") private var lastCustomPlatformText: String = ""
    
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
    @State private var status: OrderStatus = .received
    @State private var platform: Platform = .amazon
    @State private var customPlatformText = ""
    @State private var orderItems: [OrderItemEntry] = []
    @State private var attributes: [AttributeField] = []
    @State private var isEditMode = false
    @State private var showingStockItemPicker = false
    
    // Cost-related state variables
    @State private var shippingCost = 0.0
    @State private var additionalCosts = 0.0
    @State private var shippingMethod = ""
    @State private var trackingReference = ""
    @State private var additionalCostNotes = ""
    
    // Template management
    @State private var showingTemplateSheet = false
    @State private var showingSaveTemplateAlert = false
    @State private var templateName = ""
    
    struct OrderItemEntry: Identifiable {
        let id = UUID()
        var stockItem: StockItem?
        var quantity: Int = 1
        
        var isValid: Bool {
            guard let item = stockItem else { return false }
            return quantity > 0 && quantity <= item.quantityAvailable
        }
        
        var hasInsufficientStock: Bool {
            guard let item = stockItem else { return false }
            return quantity > item.quantityAvailable
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
                        ForEach(OrderStatus.enabledCases, id: \.self) { status in
                            Text(status.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    HStack {
                        Circle()
                            .fill(status.statusColor)
                            .frame(width: 8, height: 8)
                        Text(status.rawValue.capitalized)
                            .foregroundColor(status.statusColor)
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
                    .onChange(of: platform) { oldValue, newValue in
                        // Save the selected platform for future orders
                        lastSelectedPlatform = newValue.rawValue
                    }
                    
                    // Show text field when Custom is selected
                    if platform == .custom {
                        TextField("Enter custom platform name", text: $customPlatformText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 4)
                            .onChange(of: customPlatformText) { oldValue, newValue in
                                // Save the custom platform text
                                lastCustomPlatformText = newValue
                            }
                    }
                } else {
                    Text(platform == .custom && !customPlatformText.isEmpty ? customPlatformText : platform.rawValue)
                        .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var shippingAndCostsSection: some View {
        Section("Shipping & Additional Costs") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Shipping Method")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    TextField("e.g. Standard, Express, Pickup", text: $shippingMethod)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(shippingMethod.isEmpty ? "—" : shippingMethod)
                        .padding(.vertical, 8)
                }
            }
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Tracking")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    TextField("Tracking Reference", text: $trackingReference)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(trackingReference.isEmpty ? "—" : trackingReference)
                        .padding(.vertical, 8)
                }
            }
            
            
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Shipping Cost")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    TextField("0.00", value: $shippingCost, format: .currency(code: "GBP"))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                } else {
                    Text(shippingCost, format: .currency(code: "GBP"))
                        .padding(.vertical, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Additional Costs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if mode.isEditable || isEditMode {
                    TextField("0.00", value: $additionalCosts, format: .currency(code: "GBP"))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                } else {
                    Text(additionalCosts, format: .currency(code: "GBP"))
                        .padding(.vertical, 8)
                }
            }
            
            if mode.isEditable || isEditMode {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Additional Cost Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g. Handling fee, Tax, Insurance", text: $additionalCostNotes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
            } else if !additionalCostNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Additional Cost Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(additionalCostNotes)
                        .padding(.vertical, 8)
                }
            }
            
            // Total Cost Summary
            if shippingCost > 0 || additionalCosts > 0 {
                Divider()
                VStack(spacing: 4) {
                    HStack {
                        Text("Items Total:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(totalOrderValue, format: .currency(code: "GBP"))
                    }
                    
                    if shippingCost > 0 {
                        HStack {
                            Text("Shipping:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(shippingCost, format: .currency(code: "GBP"))
                        }
                    }
                    
                    if additionalCosts > 0 {
                        HStack {
                            Text("Additional Costs:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(additionalCosts, format: .currency(code: "GBP"))
                        }
                    }
                    
                    Divider()
                    HStack {
                        Text("Grand Total:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(totalOrderValue + shippingCost + additionalCosts, format: .currency(code: "GBP"))
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            
            
            Form {
                orderInformationSection
                
                shippingAndCostsSection
                
//                Section {
//                    ForEach($orderItems) { $orderItem in
//                        VStack(alignment: .leading, spacing: 8) {
////                            HStack {
////                                VStack(alignment: .leading) {
////                                    Text("Item")
////                                        .font(.caption)
////                                        .foregroundColor(.secondary)
////                                    if mode.isEditable || isEditMode {
////                                        Button(action: {
////                                            // This would open a stock item picker
////                                            showingStockItemPicker = true
////                                        }) {
////                                            HStack {
////                                                Text(orderItem.stockItem?.name ?? "Select Item")
////                                                    .foregroundColor(orderItem.stockItem == nil ? .secondary : .primary)
////                                                Spacer()
////                                                Image(systemName: "chevron.right")
////                                                    .foregroundColor(.secondary)
////                                                    .font(.caption)
////                                            }
////                                        }
////                                        .buttonStyle(.plain)
////                                    } else {
////                                        VStack(alignment: .leading, spacing: 2) {
////                                            Text(orderItem.stockItem?.name ?? "—")
////                                            
////                                            // Display category if available
////                                            if let category = orderItem.stockItem?.category {
////                                                HStack {
////                                                    Image(systemName: "largecircle.fill.circle")
////                                                        .font(.caption2)
////                                                        .foregroundStyle(category.color)
////                                                    Text(category.name)
////                                                        .font(.caption2)
////                                                        .foregroundColor(.secondary)
////                                                }
////                                            }
////                                        }
////                                    }
////                                }
////                                
////                                VStack(alignment: .leading) {
////                                    Text("Quantity")
////                                        .font(.caption)
////                                        .foregroundColor(.secondary)
////                                    if mode.isEditable || isEditMode {
////                                        VStack(alignment: .leading, spacing: 2) {
////                                            TextField("Qty", value: $orderItem.quantity, format: .number)
////                                                .textFieldStyle(.roundedBorder)
////                                                .keyboardType(.numberPad)
////                                                .frame(width: 60)
////                                                .overlay(
////                                                    RoundedRectangle(cornerRadius: 6)
////                                                        .stroke(orderItem.hasInsufficientStock ? Color.red : Color.clear, lineWidth: 1)
////                                                )
////                                            
////                                            if let stockItem = orderItem.stockItem {
////                                                Text("Available: \(stockItem.quantityAvailable)")
////                                                    .font(.caption2)
////                                                    .foregroundColor(orderItem.hasInsufficientStock ? .red : .secondary)
////                                            }
////                                            
////                                            if orderItem.hasInsufficientStock {
////                                                Text("Insufficient stock")
////                                                    .font(.caption2)
////                                                    .foregroundColor(.red)
////                                            }
////                                        }
////                                    } else {
////                                        Text("\(orderItem.quantity)")
////                                    }
////                                }
////                                
////                                if mode.isEditable || isEditMode {
////                                    Button(action: {
////                                        removeOrderItem(orderItem)
////                                    }) {
////                                        Image(systemName: "minus.circle.fill")
////                                            .foregroundColor(.red)
////                                    }
////                                }
////                            }
//                            
//                      
//                      
//                            
//                         
//                        }
//                        .padding(.vertical, 4)
//                    }
//                    
//                    if mode.isEditable || isEditMode {
//                        Button(action: addOrderItemWithPicker) {
//                            Label("Add Item", systemImage: "plus.circle")
//                        }
//                    }
//                } header: {
//                    HStack {
//                        Text("Order Items")
//                        Spacer()
//                        if !orderItems.isEmpty {
//                            Text("Total: \(totalOrderValue, format: .currency(code: "GBP"))")
//                                .font(.caption)
//                                .fontWeight(.semibold)
//                        }
//                    }
//                }
//                
                
                let validOrderItems = orderItems.filter { $0.isValid }
                
                
                if (!validOrderItems.isEmpty){
                    
                    
                    VStack{
                    
                    ForEach($orderItems) { $orderItem in
                        
                        if let stockItem = orderItem.stockItem {
                            
                            
                            
                            
                            
                            HStack {
                                
                                
                                Text("\(orderItem.quantity) x \(orderItem.stockItem?.name ?? "—")")
                                
                                Spacer()
                                
                                Text("Total: \(orderItem.totalPrice, format: .currency(code: stockItem.currency.rawValue.uppercased()))")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                
                                
                            }
                            
                        }
                           
                         
                    
                        
                        }
                        if mode.isEditable || isEditMode {
                
                   
                                let total = formatAsCurrency(validOrderItems.reduce(0) { $0 + $1.totalPrice })
                                
                                
                                HStack{
                                    
                                    Spacer()
                                    Text("Order Total: \(total)")
                                }
                            }
                        
                    }
                    
                }
                if mode.isEditable || isEditMode {
                    
            
                        
                        
                       
                        Button(action: addOrderItemWithPicker) {
                            Label(validOrderItems.isEmpty ? "Add items"  :  "Edit items", systemImage: validOrderItems.isEmpty ? "plus.circle" : "pencil.circle" )
                        }
                    
                  
                }
                
                
                
                // Always show Custom Attributes section when editing to allow template access
                if !attributes.isEmpty || mode.isEditable || isEditMode {
                    Section(attributes.isEmpty  ? "" : "Custom Attributes") {
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
            let existingQuantities: [StockItem.ID: Int] = {
                var quantities: [StockItem.ID: Int] = [:]
                for orderItem in orderItems {
                    if let stockItem = orderItem.stockItem {
                        quantities[stockItem.id] = orderItem.quantity
                    }
                }
                return quantities
            }()
            
            StockItemPickerView(stockItems: stockItems, existingQuantities: existingQuantities) { selectedItem, quantity in
                // Check if this item already exists in the order
                if let existingIndex = orderItems.firstIndex(where: { $0.stockItem?.id == selectedItem.id }) {
                    if quantity == 0 {
                        // Remove item if quantity is 0
                        orderItems.remove(at: existingIndex)
                    } else {
                        // Update existing item
                        orderItems[existingIndex].quantity = quantity
                    }
                } else if quantity > 0 {
                    // Add new item (only if quantity > 0)
                    var newOrderItem = OrderItemEntry()
                    newOrderItem.stockItem = selectedItem
                    newOrderItem.quantity = quantity
                    orderItems.append(newOrderItem)
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
    
    private func shouldReturnStockToInventory(_ status: OrderStatus) -> Bool {
        return status == .canceled || status == .failed || status == .refunded
    }
    

    
    private func loadOrderData() {
        if let existingOrder = order {
            date = existingOrder.date
            customerName = existingOrder.customerName ?? ""
            status = existingOrder.status
            platform = existingOrder.platform
            
            // Load shipping and cost data
            shippingCost = existingOrder.shippingCost
            additionalCosts = existingOrder.additionalCosts
            shippingMethod = existingOrder.shippingMethod ?? ""
            trackingReference = existingOrder.trackingReference ?? ""
            additionalCostNotes = existingOrder.additionalCostNotes ?? ""
            
            orderItems = existingOrder.items.map { orderItem in
                OrderItemEntry(stockItem: orderItem.stockItem, quantity: orderItem.quantity)
            }
            
            // Load attributes and handle custom platform text
            var loadedAttributes: [AttributeField] = []
            
            for (key, value) in existingOrder.attributes {
                if key == "customPlatformName" {
                    // Load custom platform text
                    customPlatformText = value
                } else {
                    // Regular attribute
                    loadedAttributes.append(AttributeField(key: key, value: value))
                }
            }
            
            attributes = loadedAttributes
        } else {
            // For new orders, initialize with user's last chosen platform
            if let savedPlatform = Platform.allCases.first(where: { $0.rawValue == lastSelectedPlatform }) {
                platform = savedPlatform
                // If the saved platform is custom, load the saved custom text
                if savedPlatform == .custom {
                    customPlatformText = lastCustomPlatformText
                }
            }
            
            // For new orders, start with one empty item
            addOrderItem()
            
            // Load default template if available
            loadDefaultTemplate()
        }
    }
    
    
    func formatAsCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    
    private func addOrderItem() {
        orderItems.append(OrderItemEntry())
    }
    
    private func addOrderItemWithPicker() {
        orderItems.append(OrderItemEntry())
        showingStockItemPicker = true
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
        var attributesDict = Dictionary(
            uniqueKeysWithValues: attributes
                .filter { !$0.key.isEmpty }
                .map { ($0.key, $0.value) }
        )
        
        // Store custom platform text if platform is custom
        if platform == .custom && !customPlatformText.isEmpty {
            attributesDict["customPlatformName"] = customPlatformText
        }
        
        if let existingOrder = order {
            // Check if we need to return stock to inventory due to status change
            let oldStatus = existingOrder.status
            let newStatus = status
            
            // If changing to a status that should return stock, and the old status didn't return stock
            if shouldReturnStockToInventory(newStatus) && !shouldReturnStockToInventory(oldStatus) {
                // Return items to stock
                for orderItem in existingOrder.items {
                    if let stockItem = orderItem.stockItem {
                        stockItem.quantityAvailable += orderItem.quantity
                    }
                }
            }
            // If changing from a status that returned stock to one that doesn't, reduce stock again
            else if !shouldReturnStockToInventory(newStatus) && shouldReturnStockToInventory(oldStatus) {
                // Remove items from stock
                for orderItem in existingOrder.items {
                    if let stockItem = orderItem.stockItem {
                        stockItem.quantityAvailable -= orderItem.quantity
                    }
                }
            }
            
            // Update existing order
            existingOrder.date = date
            existingOrder.customerName = customerName.isEmpty ? nil : customerName
            existingOrder.status = status
            existingOrder.platform = platform
            existingOrder.attributes = attributesDict
            
            // Update shipping and cost data
            existingOrder.shippingCost = shippingCost
            existingOrder.additionalCosts = additionalCosts
            existingOrder.shippingMethod = shippingMethod.isEmpty ? nil : shippingMethod
            existingOrder.trackingReference = trackingReference.isEmpty ? nil : trackingReference
            existingOrder.additionalCostNotes = additionalCostNotes.isEmpty ? nil : additionalCostNotes
            
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
            
            // Add order items and reduce stock quantities
            for orderItemEntry in validOrderItems {
                let orderItem = OrderItem(quantity: orderItemEntry.quantity, stockItem: orderItemEntry.stockItem)
                orderItem.order = newOrder
                newOrder.items.append(orderItem)
                
                // Reduce stock quantity
                if let stockItem = orderItemEntry.stockItem {
                    stockItem.quantityAvailable -= orderItemEntry.quantity
                }
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


#Preview {
    OrderDetailView(mode: .add)
}
