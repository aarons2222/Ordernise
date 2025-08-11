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

    
    @StateObject private var localeManager = LocaleManager.shared
    @State var toastie: Toastie? = nil
 
    
    // Custom dismiss function that clears toast error state
    private func dismissWithCleanup() {
        toastie = nil // Clear any error toast
        dismiss()
    }
    
    // AppStorage for remembering user preferences
    @AppStorage("lastSelectedPlatform") private var lastSelectedPlatform: String = Platform.amazon.rawValue
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
    
    // ViewModel for centralized state management
    @StateObject private var viewModel = OrderDetailViewViewModel()
    
    @State private var date = Date()
    @State private var orderReference = ""
    @State private var customerName = ""
    @State private var status: OrderStatus = .received
    @State private var platform: Platform = Platform.enabledPlatforms.first ?? .amazon
    @State private var customPlatformText = ""
    @State private var isEditMode = false
    @State private var showingStockItemPicker = false
    @State private var currentOrderItemIndex: Int?
    @State private var showingOrderFieldSettings = false
    // Field preferences - reactive to UserDefaults changes
    @State private var fieldPreferences = UserDefaults.standard.orderFieldPreferences
    @State private var customFieldValues: [UUID: String] = [:]
    
    // Cost-related state variables
    @State private var shippingCost = 0.0
    @State private var sellingFees = 0.0
    @State private var additionalCosts = 0.0
    @State private var shippingMethod = ""
    @State private var trackingReference = ""
    @State private var customerShippingCharge = 0.0
    @State private var additionalCostNotes = ""
    

    


    
    @State private var deliveryMethod: DeliveryMethod = .collected
    @State private var hasLoadedInitialData = false
    
    @FocusState private var focusedField: Bool?
    
    // Use type aliases to reference ViewModel types
    typealias OrderItemEntry = OrderDetailViewViewModel.OrderItemEntry
    
    


        
  
    @State private var errorTitle = ""
    @State private var errorSubTitle = ""
    
    
 
    
    
    
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
        viewModel.orderItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    // Total revenue including items and customer shipping charge
    var totalRevenue: Double {
        totalOrderValue + customerShippingCharge
    }
    
    // Total charges (costs that reduce profit)
    var totalCharges: Double {
        shippingCost + sellingFees + additionalCosts
    }
    
    // Net order total (total revenue minus charges)
    var netOrderTotal: Double {
        totalRevenue - totalCharges
    }
    
    // Total cost of goods (for profit calculation)
    var totalCostOfGoods: Double {
        viewModel.orderItems.reduce(0) { $0 + ($1.stockItem?.cost ?? 0.0) * Double($1.quantity) }
    }
    
    // Profit (total revenue minus all costs including COGS and charges)
    var orderProfit: Double {
        totalRevenue - totalCostOfGoods - totalCharges
    }
    
    
          
      
    
    
    // Dynamic field rendering based on user preferences
    private var dynamicFieldsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(fieldPreferences.visibleFields) { fieldItem in
                fieldView(for: fieldItem)
            }
        }
    }
    
    @ViewBuilder
    private func fieldView(for fieldItem: OrderFieldItem) -> some View {
        if fieldItem.isBuiltIn, let builtInField = fieldItem.builtInField {
            switch builtInField {
                    
                case .orderDate:
                    HStack() {
                        Text("Order Date")
                        Spacer()
                        MyDatePicker(selectedDate: $date)
                    }
                    
                case .orderReference:
                    ListSection(title: "Order Reference") {
                        CustomTextField(
                            text: $orderReference,
                            placeholder: "Order Reference",
                            systemImage: "number",
                            isSecure: false
                        )
                        .focused($focusedField, equals: true)
                    }
                    
                case .customerName:
                    ListSection(title: "Customer Name") {
                        CustomTextField(
                            text: $customerName,
                            placeholder: "Customer Name",
                            systemImage: "person",
                            isSecure: false
                        )
                        .focused($focusedField, equals: true)
                    }
                    
                case .orderStatus:
                    ListSection(title: "Order Status") {
                        StatusDropdownMenu(selection: $status)
                    }
                case .platform:
                    ListSection(title: "Platform") {
                        PlatformDropdownMenu(selection: $platform)
                            .onChange(of: platform) { oldValue, newValue in
                                // Save the selected platform for future orders
                                lastSelectedPlatform = newValue.rawValue
                            }
                        
                        // Show text field when Custom is selected
                        if platform == .custom {
                            Spacer(minLength: 10)
                            CustomTextField(
                                text: $customPlatformText,
                                placeholder: "Enter platform name",
                                systemImage: "square.stack.3d.down.forward",
                                isSecure: false
                            )
                            .focused($focusedField, equals: true)
                            .onChange(of: customPlatformText) { oldValue, newValue in
                                // Save the custom platform text
                                lastCustomPlatformText = newValue
                            }
                        }
                    }
                    
                case .shipping:
                    // Combined delivery and shipping section
                    VStack(spacing: 16) {
                        // Delivery picker in its own stable section
                        HStack {
                            Spacer()
                            DeliveryPicker(selection: $deliveryMethod)
                            Spacer()
                        }
                        
                        // Conditional shipping fields
                        if deliveryMethod != .collected {
                            VStack(spacing: 16) {
                                ListSection(title: "Shipping Method") {
                                    CustomTextField(
                                        text: $shippingMethod,
                                        placeholder: "e.g. Standard, Express, Pickup",
                                        systemImage: "envelope.front",
                                        isSecure: false
                                    )
                                    .focused($focusedField, equals: true)
                                }
                                
                                ListSection(title: "Tracking") {
                                    CustomTextField(
                                        text: $trackingReference,
                                        placeholder: "Tracking Reference",
                                        systemImage: "number",
                                        isSecure: false
                                    )
                                    .focused($focusedField, equals: true)
                                }
                                
                                ListSection(title: "Customer Shipping Charge") {
                                    CustomNumberField(
                                        value: (mode.isEditable || isEditMode) ? $customerShippingCharge : .constant(customerShippingCharge),
                                        placeholder: "Amount charged to customer",
                                        systemImage: localeManager.currencySymbolName
                                    )
                                    .focused($focusedField, equals: mode.isEditable || isEditMode)
                                }
                                
                                ListSection(title: "Shipping Costs") {
                                    CustomNumberField(
                                        value: {
                                            let isEditable = (mode.isEditable || isEditMode)
                                            print("🔗 [OrderDetailView] Shipping Cost binding - isEditable: \(isEditable), mode: \(mode), isEditMode: \(isEditMode)")
                                            return isEditable ? $shippingCost : .constant(shippingCost)
                                        }(),
                                        placeholder: "Shipping Costs",
                                        systemImage: localeManager.currencySymbolName
                                    )
                                    .focused($focusedField, equals: mode.isEditable || isEditMode)
                                }
                            }
                        }
                    }
                    
                case .sellingFees:
                    ListSection(title: "Selling Fees") {
                    CustomNumberField(
                        value: (mode.isEditable || isEditMode) ? $sellingFees : .constant(sellingFees),
                        placeholder: "Selling Fees",
                        systemImage: localeManager.currencySymbolName
                    )
                    .focused($focusedField, equals: mode.isEditable || isEditMode)
                }
                
            case .additionalCosts:
                ListSection(title: "Additional Costs") {
                    CustomNumberField(
                        value: (mode.isEditable || isEditMode) ? $additionalCosts : .constant(additionalCosts),
                        placeholder: "Additional Costs",
                        systemImage: localeManager.currencySymbolName
                    )
                    .focused($focusedField, equals: mode.isEditable || isEditMode)
                }
                

            case .notes:
                ListSection(title: "Notes") {
                    CustomTextEditor(text: $additionalCostNotes,
                                     placeholder: "e.g. Handling fee, Tax, Insurance",
                                     systemImage: "text.alignleft",
                                     isFocused: $focusedField)
                }
                
            case .itemsSection:
                // Combined Add Items Section (Order Items + Add Button)
                VStack(spacing: 16) {
                    // Order Items Display
                    let validOrderItems = viewModel.orderItems.filter { $0.isValid }
                    if !validOrderItems.isEmpty {
                        ListSection(title: "Items") {
                            VStack {
                                ForEach($viewModel.orderItems) { $orderItem in
                                    if let stockItem = orderItem.stockItem {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(alignment: .top) {
                                                Text("\(orderItem.quantity) × \(orderItem.stockItem?.name ?? "—")")
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Text(orderItem.totalPrice, format: .currency(code: stockItem.currency.rawValue.uppercased()))
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                     
                                        }
                                        .padding(.vertical, 6)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Add Items Button (always present)
                    GlobalButton(
                        title: viewModel.orderItems.filter { $0.isValid }.isEmpty ? "Add items" : "Edit items",
                        showIcon: true,
                        icon: viewModel.orderItems.filter { $0.isValid }.isEmpty ? "plus.circle" : "pencil.circle",
                        action: {
                            addOrderItemWithPicker()
                        }
                    )
                }
            }
        } else if let customField = fieldItem.customField {
            // Render custom field
            customFieldView(for: customField)
        }
    }
    
    @ViewBuilder
    private func customFieldView(for customField: CustomOrderField) -> some View {
        let fieldValue = Binding<String>(
            get: { customFieldValues[customField.id] ?? "" },
            set: { customFieldValues[customField.id] = $0 }
        )
        
        // Since we simplified custom fields to only be text fields, we only handle .text case
        ListSection(title: customField.name) {
            CustomTextField(
                text: fieldValue,
                placeholder: customField.placeholder,
                systemImage: "textformat",
                isSecure: false
            )
            .focused($focusedField, equals: true)
        }
    }
                
                
        

    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderWithButton(
                    title: {
                        if mode == .view && !isEditMode {
                            return "Order"
                        } else if mode == .view && isEditMode {
                            return "Edit Order"
                        } else {
                            return "New Order"
                        }
                    }(),
                    buttonContent: "Save",
                    isButtonImage: false,
                    showTrailingButton: true,
                    showLeadingButton: true,
                    onButtonTap: {
                        saveOrder()
                    }
                )
                
                ScrollView(showsIndicators: false) {
                    Spacer(minLength: 10)
                    
                    // Dynamic Fields Section
                    dynamicFieldsSection
                        .padding(.horizontal)
                    
                    // Financial Summary
                    VStack(alignment: .trailing, spacing: 8) {
                        // Items subtotal
                        HStack {
                            Spacer()
                            Text("Items Total: \(totalOrderValue, format: localeManager.currencyFormatStyle)")
                                .font(.body)
                        }
                        
                        // Customer shipping charge (if any)
                        if customerShippingCharge > 0 {
                            HStack {
                                Spacer()
                                Text("Shipping Revenue: +\(customerShippingCharge, format: localeManager.currencyFormatStyle)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Total revenue
                        if customerShippingCharge > 0 {
                            HStack {
                                Spacer()
                                Text("Total Revenue: \(totalRevenue, format: localeManager.currencyFormatStyle)")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        // Charges section
                        if totalCharges > 0 {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Charges:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if shippingCost > 0 {
                                    HStack {
                                        Spacer()
                                        Text("Shipping: -\(shippingCost, format: localeManager.currencyFormatStyle)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if sellingFees > 0 {
                                    HStack {
                                        Spacer()
                                        Text("Selling Fees: -\(sellingFees, format: localeManager.currencyFormatStyle)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if additionalCosts > 0 {
                                    HStack {
                                        Spacer()
                                        Text("Additional: -\(additionalCosts, format: localeManager.currencyFormatStyle)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Net total
                        HStack {
                            Spacer()
                            Text("Order Total: \(netOrderTotal, format: localeManager.currencyFormatStyle)")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        // Profit
                        HStack {
                            Spacer()
                            Text("Profit: \(orderProfit, format: localeManager.currencyFormatStyle)")
                                .font(.subheadline)
                                .foregroundColor(orderProfit >= 0 ? .green : .red)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.horizontal)
                    
                    Color.clear.frame(height: 40)
                }
           
              

                
                
                
            }
            
     

            .navigationBarHidden(true)
            
            

        }
        .navigationBarHidden(true)
        .overlay(alignment: .bottomTrailing) {
            Button {
                showingOrderFieldSettings = true
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
        .fullScreenCover(isPresented: $showingOrderFieldSettings) {
            OrderFieldSettings()
        }
        .sheet(isPresented: $showingStockItemPicker) {
            StockItemPickerView { stockItem, quantity in
                if let index = currentOrderItemIndex {
                    viewModel.orderItems[index].stockItem = stockItem
                    viewModel.orderItems[index].quantity = quantity
                } else {
                    // Add new item
                    var newOrderItem = OrderItemEntry()
                    newOrderItem.stockItem = stockItem
                    newOrderItem.quantity = quantity
                    viewModel.orderItems.append(newOrderItem)
                }
                showingStockItemPicker = false
                currentOrderItemIndex = nil
            }
        }
        .onAppear {
            // Only load data once initially, don't reload after saves in edit mode
            if !hasLoadedInitialData {
                print("🔄 [OrderDetailView] Initial data load on appear")
                loadOrderData()
                hasLoadedInitialData = true
            }
            // Refresh field preferences when view appears
            fieldPreferences = UserDefaults.standard.orderFieldPreferences
        }
        .onChange(of: showingOrderFieldSettings) { _, isShowing in
            if !isShowing {
                // Refresh field preferences when sheet dismisses
                fieldPreferences = UserDefaults.standard.orderFieldPreferences
            }
        }
        .toastieView(toast: $toastie)
        .onDisappear {
            // Clear toast error state when view disappears to prevent showing error again
            toastie = nil
        }
    }
    
    
    @ViewBuilder
    func RowView(
        _ image: String,
        _ title: String,
        _ description: String,
        action: @escaping () -> Void
    ) -> some View {
        
        
        CustomCardView{
            
            HStack(spacing: 10) {
                Image(systemName: image)
                    .font(.title2)
                    .foregroundStyle(Color.appTint)
                    .frame(width: 45, height: 45)
                
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.text)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
     
            .contentShape(.rect)
            .onTapGesture {
                action()
            }
        }
    }
    
    
    

    
    private var isValidOrder: Bool {
        !viewModel.orderItems.isEmpty && viewModel.orderItems.allSatisfy { $0.isValid }
    }
    
    private func shouldReturnStockToInventory(_ status: OrderStatus) -> Bool {
        return status == .canceled || status == .failed || status == .refunded
    }
    

    
    private func loadOrderData() {
        if let existingOrder = order {
            print("📊 [OrderDetailView] Loading existing order data:")
            print("  - Order ID: \(existingOrder.id)")
            print("  - Order Reference: '\(existingOrder.orderReference ?? "nil")'")
            print("  - Shipping Cost: \(existingOrder.shippingCost)")
            print("  - Selling Fees: \(existingOrder.sellingFees)")
            print("  - Additional Costs: \(existingOrder.additionalCosts)")
            print("  - Shipping Method: '\(existingOrder.shippingMethod ?? "nil")'")
            print("  - Tracking Reference: '\(existingOrder.trackingReference ?? "nil")'")
            print("  - Customer Shipping Charge: \(existingOrder.customerShippingCharge)")
            print("  - Additional Cost Notes: '\(existingOrder.additionalCostNotes ?? "nil")'")
            
            date = existingOrder.date
            orderReference = existingOrder.orderReference ?? ""
            customerName = existingOrder.customerName ?? ""
            status = existingOrder.status
            platform = existingOrder.platform
            
            // Load shipping and cost data
            shippingCost = existingOrder.shippingCost
            sellingFees = existingOrder.sellingFees
            additionalCosts = existingOrder.additionalCosts
            shippingMethod = existingOrder.shippingMethod ?? ""
            trackingReference = existingOrder.trackingReference ?? ""
            customerShippingCharge = existingOrder.customerShippingCharge
            additionalCostNotes = existingOrder.additionalCostNotes ?? ""
            deliveryMethod = existingOrder.deliveryMethod ?? .collected
            

            
            print("📊 [OrderDetailView] State variables after loading:")
            print("  - orderReference state: '\(orderReference)'")
            print("  - shippingCost state: \(shippingCost)")
            print("  - sellingFees state: \(sellingFees)")
            print("  - additionalCosts state: \(additionalCosts)")
            print("  - shippingMethod state: '\(shippingMethod)'")
            print("  - trackingReference state: '\(trackingReference)'")
            print("  - customerShippingCharge state: \(customerShippingCharge)")
            print("  - additionalCostNotes state: '\(additionalCostNotes)'")
            print("📊 [OrderDetailView] ----------------------")
            
            // Load custom field values from Order's attributes
            customFieldValues = [:]
            for fieldItem in fieldPreferences.fieldItems {
                if let customField = fieldItem.customField {
                    let key = customField.id.uuidString
                    // Load existing value from Order's attributes, or default to empty string
                    customFieldValues[customField.id] = existingOrder.attributes[key] ?? ""
                }
            }
            
            // Load order items using ViewModel
            viewModel.loadOrderData(from: existingOrder)
            
            // Auto-enable edit mode for existing orders so numeric fields are editable
            isEditMode = true
            print("✏️ [OrderDetailView] Auto-enabled edit mode for existing order")
        } else {
            // For new orders, initialize with user's last chosen platform if it's still enabled
            if let savedPlatform = Platform.allCases.first(where: { $0.rawValue == lastSelectedPlatform }),
               Platform.enabledPlatforms.contains(savedPlatform) {
                platform = savedPlatform
                // If the saved platform is custom, load the saved custom text
                if savedPlatform == .custom {
                    customPlatformText = lastCustomPlatformText
                }
            } else {
                // If saved platform is disabled or not found, use first enabled platform
                platform = Platform.enabledPlatforms.first ?? .amazon
            }
            
            // For new orders, start with one empty item
            addOrderItem()
            
        
        }
    }
    
    
    func formatAsCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    
    private func addOrderItem() {
        viewModel.orderItems.append(OrderItemEntry())
    }
    

    

    
    private func addOrderItemWithPicker() {
        viewModel.orderItems.append(OrderItemEntry())
        showingStockItemPicker = true
    }
    
    private func removeOrderItem(_ orderItem: OrderDetailViewViewModel.OrderItemEntry) {
        viewModel.orderItems.removeAll { $0.id == orderItem.id }
    }
    


    
    private func saveOrder() {
        let validOrderItems = viewModel.orderItems.filter { $0.isValid }
        
        // Validation only for new orders
        if order == nil {
            var missingFields = [String]()
            
            if customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                missingFields.append("Customer Name")
            }
            
            if validOrderItems.isEmpty {
                missingFields.append("Order Item")
            }
            
            if !missingFields.isEmpty {
                errorTitle = "Missing Required Fields"
                errorSubTitle = "Please fill in: \(missingFields.joined(separator: ", "))"
                
       
                toastie = Toastie(type: .error, title: errorTitle, message: errorSubTitle)
                return
            }
        }
        
  
        
        if let existingOrder = order {
            print("💾 [OrderDetailView] Saving existing order changes:")
            print("  - Order ID: \(existingOrder.id)")
            print("  - Current state values:")
            print("    - orderReference: '\(orderReference)'")
            print("    - shippingCost: \(shippingCost)")
            print("    - sellingFees: \(sellingFees)")
            print("    - additionalCosts: \(additionalCosts)")
            print("    - shippingMethod: '\(shippingMethod)'")
            print("    - trackingReference: '\(trackingReference)'")
            print("    - additionalCostNotes: '\(additionalCostNotes)'")
            
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
            existingOrder.orderReference = orderReference.isEmpty ? nil : orderReference
            existingOrder.customerName = customerName.isEmpty ? nil : customerName
            existingOrder.status = status
            existingOrder.platform = platform
            
            // Update shipping and cost data
            existingOrder.shippingCost = shippingCost
            existingOrder.sellingFees = sellingFees
            existingOrder.additionalCosts = additionalCosts
            existingOrder.shippingMethod = shippingMethod.isEmpty ? nil : shippingMethod
            existingOrder.trackingReference = trackingReference.isEmpty ? nil : trackingReference
            existingOrder.customerShippingCharge = customerShippingCharge
            existingOrder.additionalCostNotes = additionalCostNotes.isEmpty ? nil : additionalCostNotes
            existingOrder.deliveryMethod = deliveryMethod
            
            // Save custom field values to attributes
            var attributesToSave: [String: String] = [:]
            for (fieldId, value) in customFieldValues {
                let key = fieldId.uuidString
                attributesToSave[key] = value
            }
            existingOrder.attributes = attributesToSave
            
            // Calculate and set revenue and profit automatically after order items are updated
            
            print("💾 [OrderDetailView] After updating order object:")
            print("  - existingOrder.orderReference: '\(existingOrder.orderReference ?? "nil")'")
            print("  - existingOrder.shippingCost: \(existingOrder.shippingCost)")
            print("  - existingOrder.sellingFees: \(existingOrder.sellingFees)")
            print("  - existingOrder.additionalCosts: \(existingOrder.additionalCosts)")
            print("  - existingOrder.shippingMethod: '\(existingOrder.shippingMethod ?? "nil")'")
            print("  - existingOrder.trackingReference: '\(existingOrder.trackingReference ?? "nil")'")
            print("  - existingOrder.additionalCostNotes: '\(existingOrder.additionalCostNotes ?? "nil")'")
            print("💾 [OrderDetailView] Current @State values during save:")
            print("  - @State shippingCost: \(shippingCost)")
            print("  - @State sellingFees: \(sellingFees)")
            print("  - @State additionalCosts: \(additionalCosts)")
            print("  - @State customerShippingCharge: \(customerShippingCharge)")
            print("  - Items Total: \(totalOrderValue)")
            print("  - Customer Shipping Revenue: \(customerShippingCharge)")
            print("  - Total Revenue: \(totalRevenue)")
            print("  - Total Charges: \(totalCharges)")
            print("  - Net Order Total: \(netOrderTotal)")
            print("  - Order Profit: \(orderProfit)")
            print("💾 [OrderDetailView] ----------------------")
            
            // Remove existing order items
            for item in existingOrder.items {
                modelContext.delete(item)
            }
            
            // Add new order items
            for orderItemEntry in validOrderItems {
                let orderItem = OrderItem(quantity: orderItemEntry.quantity, stockItem: orderItemEntry.stockItem)
                orderItem.order = existingOrder
            }
            
            // Calculate and set revenue and profit using OrderDetailView's logic (what user sees)
            let calculatedRevenue = totalRevenue  // Uses viewModel.orderItems calculation
            let calculatedProfit = orderProfit    // Uses OrderDetailView's profit calculation
            
            print("💾 [OrderDetailView] Using OrderDetailView calculations:")
            print("  - totalRevenue (OrderDetailView): \(calculatedRevenue)")
            print("  - orderProfit (OrderDetailView): \(calculatedProfit)")
            print("  - OLD stored revenue: \(existingOrder.revenue)")
            print("  - OLD stored profit: \(existingOrder.profit)")
            
            existingOrder.revenue = calculatedRevenue
            existingOrder.profit = calculatedProfit
            
            print("  - NEW stored revenue: \(existingOrder.revenue)")
            print("  - NEW stored profit: \(existingOrder.profit)")
            print("💾 ✅ Using OrderDetailView values instead of model computed properties")
        } else {
            // Create new order
            // Prepare custom field values for attributes
            var attributesToSave: [String: String] = [:]
            for (fieldId, value) in customFieldValues {
                let key = fieldId.uuidString
                attributesToSave[key] = value
            }
            
            let newOrder = Order(
                date: date,
                orderReference: orderReference.isEmpty ? nil : orderReference,
                customerName: customerName.isEmpty ? nil : customerName,
                status: status,
                platform: platform,
                items: [],
                shippingCost: shippingCost,
                sellingFees: sellingFees,
                additionalCosts: additionalCosts,
                shippingMethod: shippingMethod.isEmpty ? nil : shippingMethod,
                trackingReference: trackingReference.isEmpty ? nil : trackingReference,
                customerShippingCharge: customerShippingCharge,
                additionalCostNotes: additionalCostNotes.isEmpty ? nil : additionalCostNotes,
                deliveryMethod: deliveryMethod,
                attributes: attributesToSave
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
            
            // Calculate and set revenue and profit automatically
            newOrder.revenue = newOrder.itemsTotal + newOrder.customerShippingCharge
            newOrder.profit = newOrder.calculatedProfit
            
            modelContext.insert(newOrder)
        }
        
        // Save changes to context
        do {
            try modelContext.save()
            print("✅ [OrderDetailView] Save completed successfully")
            print("  - Final @State values after modelContext.save():")
            print("    - shippingCost: \(shippingCost)")
            print("    - sellingFees: \(sellingFees)")
            print("    - additionalCosts: \(additionalCosts)")
            print("    - customerShippingCharge: \(customerShippingCharge)")
            print("    - Items Total: \(totalOrderValue)")
            print("    - Customer Shipping Revenue: \(customerShippingCharge)")
            print("    - Total Revenue: \(totalRevenue)")
            print("    - Total Charges: \(totalCharges)")
            print("    - Net Order Total: \(netOrderTotal)")
            print("    - Order Profit: \(orderProfit)")
            
            toastie = Toastie(type: .success, title: "Order Saved", message: "Order has been saved successfully")
            dismiss()
        } catch {
            print("Failed to save order: \(error)")
        }
    }
}

#Preview {
    OrderDetailView(mode: .add)
}


