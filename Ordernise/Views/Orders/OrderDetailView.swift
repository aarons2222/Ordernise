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
    
    @StateObject private var localeManager = LocaleManager.shared
    @State var toastie: Toastie? = nil
 
    
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
    @State private var platform: Platform = .amazon
    @State private var customPlatformText = ""
    @State private var attributes: [AttributeField] = []
    @State private var isEditMode = false
    @State private var showingStockItemPicker = false
    @State private var currentOrderItemIndex: Int?
    @State private var showingTemplateSheet = false
    @State private var showingSaveTemplateAlert = false
    @State private var newTemplateName = ""
    @State private var showSheet = false
    // For template naming
    @State private var templateName = ""
    
    // Cost-related state variables
    @State private var shippingCost = 0.0
    @State private var sellingFees = 0.0
    @State private var additionalCosts = 0.0
    @State private var shippingMethod = ""
    @State private var trackingReference = ""
    @State private var additionalCostNotes = ""
    


    
    @State private var deliveryMethod: DeliveryMethod = .collected
    
    @FocusState private var focusedField: Bool?
    
    // Use type aliases to reference ViewModel types
    typealias OrderItemEntry = OrderDetailViewViewModel.OrderItemEntry
    typealias AttributeField = OrderDetailViewViewModel.AttributeField
    
    


        
  
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
    
    
          
      
    
    
    // Break down complex view to help compiler
    private var orderInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
   
            
            
            HStack() {
                Text("Order Date")
                Spacer()
               
                    
                    
                    MyDatePicker(selectedDate: $date)
                    
             
            }
    
            
            ListSection(title: "Order Reference") {
                CustomTextField(
                    text: $orderReference,
                    placeholder: "Order Reference",
                    systemImage: "number",
                    isSecure: false
                )
                .focused($focusedField, equals: true)
            }
            
            
            
            
            ListSection(title: "Customer Name") {
                CustomTextField(
                    text: $customerName,
                    placeholder: "Customer Name",
                    systemImage: "person",
                    isSecure: false
                )
                .focused($focusedField, equals: true)
            }
            
            
            
            ListSection(title: "Order Status") {
                StatusDropdownMenu(selection: $status)
                
            }
            
        
                
        
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
                
                
                
                
                
                
                
                
                
                
                
                
                
                
      
        
        }
    }
    
    private var ShippingSection: some View {
        
        VStack{

         
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
      
            
            

        
            
            CustomNumberField(
                value: (mode.isEditable || isEditMode) ? $shippingCost : .constant(shippingCost),
                placeholder: "Shipping Costs",
                systemImage: localeManager.currencySymbolName
            )
            .focused($focusedField, equals: mode.isEditable || isEditMode)
            
            

        }
    }
    
    private var CostsSection: some View {
        VStack{
            
            
            
            CustomNumberField(
                value: (mode.isEditable || isEditMode) ? $sellingFees : .constant(sellingFees),
                placeholder: "Selling Fees",
                systemImage: localeManager.currencySymbolName
            )
            .focused($focusedField, equals: mode.isEditable || isEditMode)
            
            
            ListSection(title: "Additional Costs") {
                
                
                CustomNumberField(
                    value: (mode.isEditable || isEditMode) ? $additionalCosts : .constant(additionalCosts),
                    placeholder: "Additional Costs",
                    systemImage: localeManager.currencySymbolName
                )
                .focused($focusedField, equals: mode.isEditable || isEditMode)
            }
            
     
            
            ListSection(title: "Notes") {
                CustomTextEditor(text: $additionalCostNotes,
                                 placeholder: "e.g. Handling fee, Tax, Insurance",
                                 systemImage: "text.alignleft",
                                 isFocused: $focusedField)
            }
      
       

//            
            // Total Cost Summary
            if shippingCost > 0 || additionalCosts > 0 {
                Divider()
                VStack(spacing: 4) {
                    HStack {
                        Text("Items Total:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(totalOrderValue, format: localeManager.currencyFormatStyle)
                    }
                    
                    if shippingCost > 0 {
                        HStack {
                            Text("Shipping:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(shippingCost, format: localeManager.currencyFormatStyle)
                        }
                    }
                    
                    if additionalCosts > 0 {
                        HStack {
                            Text("Additional Costs:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(additionalCosts, format: localeManager.currencyFormatStyle)
                        }
                    }
                    
                    
                    
                  
                }
                .font(.subheadline)
            }
        }
    }
    
    

    



    
    var body: some View {
        
        
        
            

        
        
        NavigationStack {
            
            VStack{
                
             
                
                
                HeaderWithButton(
                    title: mode == .view && !isEditMode ? "Order" : "New Order",
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
                    
                    
                    orderInformationSection
                        .padding(.horizontal)
                    
                    
                    DeliveryPicker(selection: $deliveryMethod)
                        .padding(.horizontal)
                    
                    
                    if deliveryMethod == .delivered{
                        ShippingSection
                            .padding(.horizontal)
                    }
                    
                    
                    
                    
                    
                    
                    
                    let validOrderItems = viewModel.orderItems.filter { $0.isValid }
              
                        
                    if !validOrderItems.isEmpty {
                        ListSection(title: "Items") {
                            VStack{
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
                                            
                                            if !orderItem.attributes.isEmpty {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    ForEach(orderItem.attributes) { attribute in
                                                        HStack(alignment: .center, spacing: 4) {
                                                            Image(systemName: "tag.fill")
                                                                .foregroundColor(Color.appTint)
                                                                .font(.caption2)
                                                            
                                                            Text("\(attribute.key): \(attribute.value)")
                                                                .font(.caption)
                                                                .foregroundColor(.secondary)
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                                }
                                                .padding(.leading, 4)
                                            }
                                        }
                                        .padding(.vertical, 6)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
             
           
    
                  
                         
                        GlobalButton(title: viewModel.orderItems.filter { $0.isValid }.isEmpty ? "Add items"  :  "Edit items", showIcon: true, icon: viewModel.orderItems.filter { $0.isValid }.isEmpty ? "plus.circle" : "pencil.circle",  action: {
                            addOrderItemWithPicker()
                        })
                        .padding(.horizontal, 10)

                        
                        CostsSection
                        .padding(.horizontal)
                      
                    
                HStack{
                    
                    Spacer()
                    
                    Text("Order Total: \(Double(totalOrderValue - (shippingCost + additionalCosts + sellingFees)), format: localeManager.currencyFormatStyle)")

                }
                .padding(.horizontal)
                
                
                   
   
                    Color.clear.frame(height: 40)
                    
               
                

                
                
            }
           
              

                
                
                
            }
            
     

            .navigationBarHidden(true)
            
            

        }
        
        
        
        .onAppear {
            loadOrderData()
        }
        .fullScreenCover(isPresented: $showingStockItemPicker) {
            OrderItemPickerView(
                stockItems: stockItems, 
                existingQuantities: viewModel.getExistingQuantities(), 
                existingAttributes: viewModel.getExistingAttributes()
            ) { selectedItem, quantity, attributes in
                // Use ViewModel to handle the update
                viewModel.updateStockItem(selectedItem, quantity: quantity, attributes: attributes)
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

        
  
        
        
        .overlay(alignment: .bottomTrailing) {
            
            
            
            Button{
                self.showSheet = true
            }label: {
                
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white) // icon color
                    .frame(width: 45, height: 45)
                    .background(
                        Circle()
                            .fill(Color.appTint.gradient) // circle background color
                    )
                
           
            }
            .padding(.trailing, 20)
        }
        .GenericSheet(
            isPresented: $showSheet,
            title: "Templates",
            action: {
                print("Continue tapped")
            }
        ) {
            VStack(spacing: 30) {
               
                
                
                        RowView(
                            "text.document",
                            "Save Order as Template",
                                     "Save this order as a template to use in the future"
                                 ) {
                                     showSheet = false
                                     showingSaveTemplateAlert = true
                                 }
                
                
                        RowView(
                            "document.badge.clock.fill",
                            "Load Order Template (\(orderTemplates.count) available)",
                                     "Save time, use a previously created template"
                                 ) {
                                     
                                     showSheet = false
                                     showingTemplateSheet = true
                                 }
            }
          
        }
        
//        

        
        .toastieView(toast: $toastie)
   

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
            
            // Load order items with attributes using ViewModel
            viewModel.loadOrderData(from: existingOrder)
            
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
                if savedPlatform == .amazon {
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
        viewModel.orderItems.append(OrderItemEntry())
    }
    
    private func addOrderItemWithPicker() {
        viewModel.orderItems.append(OrderItemEntry())
        showingStockItemPicker = true
    }
    
    private func removeOrderItem(_ orderItem: OrderItemEntry) {
        viewModel.orderItems.removeAll { $0.id == orderItem.id }
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
                // Convert AttributeField array to [String: String] dictionary
                let attributesDict = Dictionary(uniqueKeysWithValues: orderItemEntry.attributes.map { ($0.key, $0.value) })
                let orderItem = OrderItem(quantity: orderItemEntry.quantity, stockItem: orderItemEntry.stockItem, attributes: attributesDict)
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
                // Convert AttributeField array to [String: String] dictionary
                let attributesDict = Dictionary(uniqueKeysWithValues: orderItemEntry.attributes.map { ($0.key, $0.value) })
                let orderItem = OrderItem(quantity: orderItemEntry.quantity, stockItem: orderItemEntry.stockItem, attributes: attributesDict)
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




