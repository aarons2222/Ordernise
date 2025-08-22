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
    @Environment(\.stockManager) private var stockManager
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
    @AppStorage("lastSelectedShippingCompany") private var lastSelectedShippingCompany: String = ShippingCompany.royalMail.rawValue
    @AppStorage("lastCustomShippingCompanyText") private var lastCustomShippingCompanyText: String = ""
    
    enum Mode {
        case add
        case edit
        case view
        
        var title: String {
            switch self {
            case .add: return String(localized: "Add Order")
            case .edit: return String(localized: "Edit Order")
            case .view: return String(localized: "Order Details")
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
    
    @State private var orderReceivedDate = Date()
    @State private var orderCompletionDate = Date()
    @State private var orderReference = ""
    @State private var customerName = ""
    @State private var status: OrderStatus = .received
    @State private var platform: Platform = Platform.enabledPlatforms.first ?? .amazon
    @State private var customPlatformText = ""
    @State private var selectedShippingCompany: ShippingCompany = ShippingCompany.enabledShippingCompanies.first ?? .royalMail
    @State private var customShippingCompanyText = ""
    @State private var isEditMode = false
    @State private var showingStockItemPicker = false

    @State private var currentOrderItemIndex: Int?
    @State private var showingOrderFieldSettings = false
    // Field preferences - reactive to UserDefaults changes
    @State private var fieldPreferences = UserDefaults.standard.orderFieldPreferences
    @State private var customFieldValues: [UUID: String] = [:]
    
    // Reminder state variables
    @State private var reminderEnabled = false
    @State private var reminderTimePeriod: ReminderTimePeriod = .fifteenMinutes
    @StateObject private var notificationManager = NotificationManager.shared
    
    // Computed property for Save button validation
    private var isSaveButtonDisabled: Bool {
        // Apply same validation for both new and existing orders
        let hasValidCustomerName = !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasValidOrderItems = !viewModel.orderItems.filter { $0.isValid }.isEmpty
        let isDisabled = !(hasValidCustomerName && hasValidOrderItems)
        
        let orderType = order == nil ? "New order" : "Edit order"
        print("🔍 [Save Button State] \(orderType) - Customer: '\(customerName)', Items: \(viewModel.orderItems.count), Valid Items: \(viewModel.orderItems.filter { $0.isValid }.count), Disabled: \(isDisabled)")
        
        return isDisabled
    }
    
    // Cost-related state variables
    @State private var shippingCost = 0.0
    @State private var sellingFees = 0.0
    @State private var additionalCosts = 0.0
    @State private var shippingCompany = ""
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
        let visibleFields = fieldPreferences.visibleFields
        let _ = print("🔍 [OrderDetailView] visibleFields count: \(visibleFields.count)")
        let _ = visibleFields.forEach { field in
            if let builtIn = field.builtInField {
                print("🔍 [OrderDetailView] visible field: \(builtIn.rawValue)")
            }
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            ForEach(visibleFields) { fieldItem in
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
                    Text(String(localized: "Order Date"))
                    Spacer()
                    MyDatePicker(selectedDate: $orderReceivedDate, showFutureDate: false)
                }
                
            case .orderReference:
                ListSection(title: String(localized: "Order Reference")) {
                    CustomTextField(
                        text: $orderReference,
                        placeholder: String(localized: "Order Reference"),
                        systemImage: "number",
                        isSecure: false
                    )
                    .focused($focusedField, equals: true)
                }
                
            case .customerName:
                ListSection(title: String(localized: "Customer Name"), isRequired: true, content: {
                    CustomTextField(
                        text: $customerName,
                        placeholder: String(localized: "Customer Name"),
                        systemImage: "person",
                        isSecure: false
                    )
                    .focused($focusedField, equals: true)
                })
                
            case .orderStatus:
                ListSection(title: String(localized: "Order Status")) {
                    StatusDropdownMenu(selection: $status)
                }
            case .platform:
                ListSection(title: String(localized: "Platform")) {
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
                            placeholder: String(localized: "Enter platform name"),
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
                    ListSection(title: String(localized: "Shipping Method")) {
                        
                        
                        
                        
                        
                        SegmentedControl(
                            tabs: DeliveryMethod.allCases,
                            activeTab: $deliveryMethod,
                            height: 45,
                            font: .callout,
                            activeTint: Color(UIColor.systemBackground),
                            inActiveTint: .gray.opacity(0.8)
                        ) { size in
                            RoundedRectangle(cornerRadius: 22.5)
                                .fill(Color.appTint.gradient)
                            
                            
                        }
                        .background(
                            Capsule()
                                .fill(.thinMaterial)
                                .stroke(Color.appTint, lineWidth: 2)
                        )
                        .padding(.horizontal, 3)
                        
                        
                    }
                    
                    // Conditional shipping fields
                    if deliveryMethod != .collected {
                        
                        
                        VStack(spacing: 16) {
                            
                            ListSection(title: String(localized: "Shipping Company")) {
                                ShippingCompanyDropdownMenu(selection: $selectedShippingCompany)
                                    .onChange(of: selectedShippingCompany) { oldValue, newValue in
                                        // Save the selected shipping company for future orders
                                        lastSelectedShippingCompany = newValue.rawValue
                                        // Convert enum to string for existing shippingCompany variable
                                        if newValue == .custom {
                                            shippingCompany = customShippingCompanyText
                                        } else {
                                            shippingCompany = newValue.rawValue
                                        }
                                    }
                                
                                // Show text field when Custom is selected
                                if selectedShippingCompany == .custom {
                                    Spacer(minLength: 10)
                                    CustomTextField(
                                        text: $customShippingCompanyText,
                                        placeholder: String(localized: "Enter shipping company name"),
                                        systemImage: "envelope.front",
                                        isSecure: false
                                    )
                                    .focused($focusedField, equals: true)
                                    .onChange(of: customShippingCompanyText) { oldValue, newValue in
                                        // Save the custom shipping company text
                                        lastCustomShippingCompanyText = newValue
                                        // Update the shippingCompany string variable
                                        shippingCompany = newValue
                                    }
                                }
                            }
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            ListSection(title: String(localized: "Shipping Method")) {
                                CustomTextField(
                                    text: $shippingMethod,
                                    placeholder: String(localized: "e.g. Standard, Express, Next Day"),
                                    systemImage: "envelope.front",
                                    isSecure: false
                                )
                                .focused($focusedField, equals: true)
                            }
                            
                            ListSection(title: String(localized: "Tracking")) {
                                CustomTextField(
                                    text: $trackingReference,
                                    placeholder: String(localized: "Tracking Reference"),
                                    systemImage: "number",
                                    isSecure: false
                                )
                                .focused($focusedField, equals: true)
                            }
                            
                            ListSection(title: String(localized: "Customer Postage Charge")) {
                                CustomNumberField(
                                    value: (mode.isEditable || isEditMode) ? $customerShippingCharge : .constant(customerShippingCharge),
                                    placeholder: String(localized: "Amount charged to customer"),
                                    systemImage: localeManager.currencySymbolName
                                )
                                .focused($focusedField, equals: mode.isEditable || isEditMode)
                            }
                            
                            ListSection(title: String(localized: "Postage Costs")) {
                                CustomNumberField(
                                    value: {
                                        let isEditable = (mode.isEditable || isEditMode)
                                        print("🔗 [OrderDetailView] Shipping Cost binding - isEditable: \(isEditable), mode: \(mode), isEditMode: \(isEditMode)")
                                        return isEditable ? $shippingCost : .constant(shippingCost)
                                    }(),
                                    placeholder: String(localized: "Postage Costs"),
                                    systemImage: localeManager.currencySymbolName
                                )
                                .focused($focusedField, equals: mode.isEditable || isEditMode)
                            }
                        }
                    }
                }
                
            case .sellingFees:
                ListSection(title: String(localized: "Marketplace Fees")) {
                    CustomNumberField(
                        value: (mode.isEditable || isEditMode) ? $sellingFees : .constant(sellingFees),
                        placeholder: String(localized: "Marketplace Fees"),
                        systemImage: localeManager.currencySymbolName
                    )
                    .focused($focusedField, equals: mode.isEditable || isEditMode)
                }
                
            case .additionalCosts:
                ListSection(title: String(localized: "Other Expenses")) {
                    CustomNumberField(
                        value: (mode.isEditable || isEditMode) ? $additionalCosts : .constant(additionalCosts),
                        placeholder: String(localized: "Other Expenses"),
                        systemImage: localeManager.currencySymbolName
                    )
                    .focused($focusedField, equals: mode.isEditable || isEditMode)
                }
                
                
            case .notes:
                ListSection(title: String(localized: "Notes")) {
                    CustomTextEditor(text: $additionalCostNotes,
                                     placeholder: String(localized: "e.g. Handling fee, Tax, Insurance"),
                                     systemImage: "text.alignleft",
                                     isFocused: $focusedField)
                }
                
            case .itemsSection:
                // Combined Add Items Section (Order Items + Add Button)
                VStack(spacing: 16) {
                    // Order Items Display
                    let validOrderItems = viewModel.orderItems.filter { $0.isValid }
                    if !validOrderItems.isEmpty {
                        ListSection(title: String(localized: "Items")) {
                            
                            CustomCardView{
                                VStack {
                                    ForEach(validOrderItems.indices, id: \.self) { index in
                                        let orderItem = validOrderItems[index]
                                        if let stockItem = orderItem.stockItem {
                                            
                                            
                                            HStack {
                                                Text("\(orderItem.quantity) × \(orderItem.stockItem?.name ?? "—")")
                                                    .font(.body.bold())
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text(abs(orderItem.totalPrice).formatted(localeManager.currencyFormatStyle))
                                                    .font(.body.bold())
                                                    .foregroundColor(.primary)
                                            }
                                            
                                  
                                                .onTapGesture {
                                                    // Find the index in the full viewModel.orderItems array
                                                    if let fullIndex = viewModel.orderItems.firstIndex(where: { $0.id == orderItem.id }) {
                                                        currentOrderItemIndex = fullIndex
                                                        showingStockItemPicker = true
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 5)
                         
                            
                        }.onAppear(){
                            print("validOrderItems \(validOrderItems)")
                            
                        }
                    }
                    
                    // Add Items Button (always present)
                    GlobalButton(
                        title: viewModel.orderItems.filter { $0.isValid }.isEmpty ? String(localized: "Add items") : String(localized: "Edit items"),
                        showIcon: true,
                        icon: viewModel.orderItems.filter { $0.isValid }.isEmpty ? "plus.circle" : "pencil.circle",
                        action: {
                            addOrderItemWithPicker()
                        }
                    )
                }
                .onAppear(){
                    print("🎯 [OrderDetailView] Rendering itemsSection case")
                    
                }
            case .orderCompletionDate:
                VStack(spacing: 16) {
                    HStack() {
                        Text(String(localized: "Order Completion Date"))
                        Spacer()
                        MyDatePicker(selectedDate: $orderCompletionDate, showFutureDate: true)
                            .onChange(of: orderCompletionDate) { oldValue, newValue in
                                // Set time to 8:00 AM when date changes
                                let calendar = Calendar.current
                                let dateComponents = calendar.dateComponents([.year, .month, .day], from: newValue)
                                if let date8AM = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: calendar.date(from: dateComponents) ?? newValue) {
                                    orderCompletionDate = date8AM
                                }
                                
                                
                            }
                    }.padding(.horizontal, 5)
                    
                    // Show reminder toggle only if completion date is set and in the future
                    if orderCompletionDate > Date() {
                        
                        
                        CustomCardView{
                            VStack(spacing: 12) {
                                // Reminder toggle
                                HStack {
                                    Image(systemName: "bell")
                                        .foregroundColor(Color.appTint)
                                        .font(.title2)
                                    
                                    Text(String(localized: "Set Reminder"))
                                        .font(.body)
                                    Spacer()
                                    Toggle("", isOn: $reminderEnabled)
                                        .tint(.appTint)
                                        .labelsHidden()
                                }
                                
                                // Time period picker (only show when reminder is enabled)
                                if reminderEnabled {
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(Color.appTint)
                                            .font(.title2)
                                        Text(String(localized: "Remind me"))
                                            .font(.body)
                                        Spacer()
                                        Picker("Reminder Time", selection: $reminderTimePeriod) {
                                            ForEach(ReminderTimePeriod.allCases) { period in
                                                Text(period.localizedName)
                                                    .tag(period)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .tint(.appTint)
                                    }
                                    
                                    // Show when notification will be sent
                                    let notificationDate = orderCompletionDate.addingTimeInterval(-reminderTimePeriod.timeInterval)
                                    
                                    if notificationDate > Date() {
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "calendar.badge.clock")
                                                .foregroundColor(Color.appTint)
                                                .font(.title2)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(String(localized: "You'll be reminded on"))
                                                    .font(.body)
                                                
                                                HStack(spacing: 4) {
                                                    Text(notificationDate, style: .date)
                                                    Text("at")
                                                    Text(notificationDate, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
                                                }
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 15)

                                    } else {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundColor(.orange)
                                                .font(.title2)
                                            
                                            Text(String(localized: "Reminder time would be in the past"))
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 15)
                                    }
                                    
                                    // Permission warning if not authorized
                                    if notificationManager.authorizationStatus != .authorized {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundColor(.orange)
                                            Text(String(localized: "Notification permission required"))
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                            Spacer()
                                            Button(String(localized: "Enable")) {
                                                Task {
                                                    await notificationManager.requestPermission()
                                                }
                                            }
                                            .font(.caption)
                                            .buttonStyle(.borderless)
                                        }
                                    }
                                }
                            }
                          
                        }
                    }
                }
            } }
        else if let customField = fieldItem.customField {
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
                            return String(localized: "Order")
                        } else if mode == .view && isEditMode {
                            return String(localized: "Edit Order")
                        } else {
                            return String(localized: "New Order")
                        }
                    }(),
                    buttonContent: String(localized: "Save"),
                    isButtonImage: false,
                    showTrailingButton: true,
                    showLeadingButton: true,
                    isButtonDisabled: isSaveButtonDisabled,
                    onButtonTap: {
                        print("🔥 [OrderDetailView] Save button tapped!")
                        Task {
                            await saveOrder()
                        }
                    }
                )
                
                ScrollView(showsIndicators: false) {
                    Spacer(minLength: 10)
                    
                    // Dynamic Fields Section
                    dynamicFieldsSection
                        .padding(.horizontal)
                    
           
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Color.clear.frame(height: 10)
                        HStack{
                            
                            Text(String(localized: "Income"))
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundColor(.text)
                                .underline(true)
                            
                            Spacer()
                        }
                        
                        
                        financialRow(String(localized: "Sales Total"), value: totalOrderValue, isNegative: false)

                        
                    
                    
                        
                        // Customer shipping charge (if any)
                        if customerShippingCharge > 0 {
                            
                            
                            financialRow(String(localized: ("Shipping Income:")), value: customerShippingCharge, isNegative: false)
                            
                            
                            
                            
                          
                        }
                        
                        // Total revenue
                        if totalRevenue > 0 {
                            
                            financialRow(String(localized: ("Gross Revenue")), value: totalRevenue, isNegative: false)
                        }
                        
                        
                      
                        
                        
                        if order?.items.count ?? 0
                    > 0 {
                            
                
                            
                            financialRow(String(localized: "Cost of Goods Sold"), value: totalCostOfGoods, isNegative: true)
                            
                            
                      
                        }
              
                        
                        // Charges section
                        if totalCharges > 0 {
                            VStack(alignment: .trailing, spacing: 4) {
                                
                  
                                
                                Divider()
                                
                                HStack{
                                Text(String(localized: "Costs"))
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .foregroundColor(.text)
                                    .underline(true)
                                    Spacer()
                                }
                                
                                
                                
                                if shippingCost > 0 {
                                    
                                    
                                    
                                    financialRow(String(localized: ("Postage Cost")), value: shippingCost, isNegative: true)
                                    
                                    
                                 
                                }
                                
                                if sellingFees > 0 {
                                    
                                    financialRow(String(localized: ("Marketplace Fees")), value: sellingFees, isNegative: true)
                            
                                }
                                
                                if additionalCosts > 0 {
                                    
                                    financialRow(String(localized: ("Other Expenses")), value: additionalCosts, isNegative: true)
                             
                                }
                            }
                            
                            
                        }
                        
                     
                        
                        
                        Divider()
                        
                        HStack{
                        Text(String(localized: "Summary"))
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundColor(.text)
                            .underline(true)
                            Spacer()
                        }
                        
                    
                            financialRow(String(localized: ("Net Revenue")), value: netOrderTotal, isNegative: false)
                            
                       
                        
                     
                        
                        financialRow("Profit", value: orderProfit, isBold: true)
                        
                  
                    }
                    .padding(.horizontal, 20)
                    
                    
                    Color.clear.frame(height: 50)
                }
           
              

                
                
                
            }
            
     

            .navigationBarHidden(true)
            
         

        }
     
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
            .padding(.bottom, 10)

        }
        .fullScreenCover(isPresented: $showingOrderFieldSettings) {
            OrderFieldSettings()
        }
      
        .sheet(isPresented: $showingStockItemPicker) {
            let existingQuantities: [StockItem.ID: Int] = {
                var quantities: [StockItem.ID: Int] = [:]
                for orderItem in viewModel.orderItems {
                    if let stockItem = orderItem.stockItem {
                        quantities[stockItem.id] = orderItem.quantity
                    }
                }
                return quantities
            }()
            
            OrderItemPickerView(
                stockItems: stockItems,
                existingQuantities: existingQuantities
            ) { stockItem, quantity in
                print("📦 [Order Item Update] Item: \(stockItem.name), Quantity: \(quantity)")
                
                let oldQuantity = existingQuantities[stockItem.id] ?? 0
                let quantityDiff = quantity - oldQuantity
                
                // Update pending allocation in StockManager (don't update actual stock yet)
                stockManager?.setPendingAllocation(for: stockItem, quantity: quantityDiff)
                print("  - Pending allocation updated: \(stockItem.name), diff: \(quantityDiff)")
                
                // Find if item already exists in the order
                if let existingIndex = viewModel.orderItems.firstIndex(where: { $0.stockItem?.id == stockItem.id }) {
                    if quantity == 0 {
                        // Remove item if quantity is 0
                        print("  - Removing existing item at index \(existingIndex)")
                        viewModel.orderItems.remove(at: existingIndex)
                    } else {
                        // Update existing item quantity
                        print("  - Updating existing item at index \(existingIndex)")
                        viewModel.orderItems[existingIndex].quantity = quantity
                    }
                } else if quantity > 0 {
                    // Add new item only if quantity > 0
                    print("  - Adding new item to order")
                    var newOrderItem = OrderItemEntry()
                    newOrderItem.stockItem = stockItem
                    newOrderItem.quantity = quantity
                    newOrderItem.isFromExistingOrder = true  // Mark as existing to bypass stock validation
                    viewModel.orderItems.append(newOrderItem)
                }
                
                print("  - viewModel.orderItems count after: \(viewModel.orderItems.count)")
                print("  - Valid items count: \(viewModel.orderItems.filter { $0.isValid }.count)")
            }
        }
        .onAppear {
            // Only load data once initially, don't reload after saves in edit mode
            if !hasLoadedInitialData {
                print("🔄 [OrderDetailView] Initial data load on appear")
                loadOrderData()
                hasLoadedInitialData = true
            }
            // Clear any lingering pending changes from previous sessions
            stockManager?.clearPendingChanges()
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
            // Clear pending changes if view is dismissed without saving
            stockManager?.clearPendingChanges()
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
            print("  - Shipping Comapny: '\(existingOrder.shippingCompany ?? "nil")'")
            print("  - Shipping Method: '\(existingOrder.shippingMethod ?? "nil")'")
            print("  - Tracking Reference: '\(existingOrder.trackingReference ?? "nil")'")
            print("  - Customer Shipping Charge: \(existingOrder.customerShippingCharge)")
            print("  - Additional Cost Notes: '\(existingOrder.additionalCostNotes ?? "nil")'")
            
            orderReceivedDate = existingOrder.orderReceivedDate
            orderReference = existingOrder.orderReference ?? ""
            customerName = existingOrder.customerName ?? ""
            status = existingOrder.status
            platform = existingOrder.platform
            
            // Load shipping and cost data
            shippingCost = existingOrder.shippingCost
            sellingFees = existingOrder.sellingFees
            additionalCosts = existingOrder.additionalCosts
            shippingCompany = existingOrder.shippingCompany ?? ""
            
            // Set selectedShippingCompany enum based on the string value
            if let company = existingOrder.shippingCompany,
               let matchingCompany = ShippingCompany.allCases.first(where: { $0.rawValue == company }) {
                selectedShippingCompany = matchingCompany
            } else if let existingCompany = existingOrder.shippingCompany, !existingCompany.isEmpty {
                // If it's a custom company name, set to custom and store the text
                selectedShippingCompany = .custom
                customShippingCompanyText = existingCompany
            } else {
                selectedShippingCompany = ShippingCompany.enabledShippingCompanies.first ?? .royalMail
            }
            
            shippingMethod = existingOrder.shippingMethod ?? ""
            trackingReference = existingOrder.trackingReference ?? ""
            customerShippingCharge = existingOrder.customerShippingCharge
            additionalCostNotes = existingOrder.additionalCostNotes ?? ""
            deliveryMethod = existingOrder.deliveryMethod ?? .collected
            
            orderCompletionDate = existingOrder.orderCompletionDate ?? Date()
            
            // Load reminder settings
            reminderEnabled = existingOrder.reminderEnabled ?? false
            if let timeBeforeCompletion = existingOrder.reminderTimeBeforeCompletion,
               let timePeriod = ReminderTimePeriod.allCases.first(where: { $0.timeInterval == timeBeforeCompletion }) {
                reminderTimePeriod = timePeriod
            }

            
            print("📊 [OrderDetailView] State variables after loading:")
            print("  - orderReference state: '\(orderReference)'")
            print("  - shippingCost state: \(shippingCost)")
            print("  - sellingFees state: \(sellingFees)")
            print("  - additionalCosts state: \(additionalCosts)")
            print("  - shippingCompany state: '\(shippingCompany)'")
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
    


    private func financialRow(_ title: String, value: Double, isNegative: Bool = false, isBold: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(isBold ? .body.bold() : .body)
                .foregroundColor(isBold ? .primary : .secondary)
            Spacer()
            Text(abs(value).formatted(localeManager.currencyFormatStyle))
                .font(isBold ? .body.bold() : .body)
                .foregroundColor(isNegative ? .red : value < 0 ? .red : (isBold ? .green : .primary))
        }
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
    
    private func handleReminderScheduling(for order: Order) async {
        // Cancel existing reminder if any
        if let existingNotificationId = order.reminderNotificationId {
            notificationManager.cancelReminder(notificationId: existingNotificationId)
            order.reminderNotificationId = nil
        }
        
        // Schedule new reminder if enabled and completion date is set
        if reminderEnabled,
           let completionDate = order.orderCompletionDate,
           completionDate > Date() {
            
            let notificationId = await notificationManager.scheduleOrderCompletionReminder(
                orderId: order.id,
                orderReference: order.orderReference,
                customerName: order.customerName,
                completionDate: completionDate,
                timeBeforeCompletion: reminderTimePeriod.timeInterval
            )
            
            // Store the notification ID and reminder settings
            order.reminderEnabled = true
            order.reminderTimeBeforeCompletion = reminderTimePeriod.timeInterval
            order.reminderNotificationId = notificationId
            
            print("✅ [OrderDetailView] Scheduled reminder for order \(order.id)")
        } else {
            // Disable reminder
            order.reminderEnabled = false
            order.reminderTimeBeforeCompletion = nil
            order.reminderNotificationId = nil
            print("🔕 [OrderDetailView] Reminder disabled for order \(order.id)")
        }
    }

    private func saveOrder() async {
        print("🚀 [OrderDetailView] saveOrder() called")
        let validOrderItems = viewModel.orderItems.filter { $0.isValid }
        print("📋 [OrderDetailView] Valid order items count: \(validOrderItems.count)")
        
        // Validation checks for both new and existing orders
        var missingFields = [String]()
        
        if customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missingFields.append(String(localized: "Customer Name"))
        }
        
        if validOrderItems.isEmpty {
            missingFields.append(String(localized: "Order Item"))
        }
        
        if !missingFields.isEmpty {
            let orderType = order == nil ? "new order" : "existing order"
            print("❌ [OrderDetailView] Validation failed for \(orderType) - missing fields: \(missingFields)")
            errorTitle = String(localized: "Missing Required Fields")
            errorSubTitle = "\(String(localized: "Please fill in: "))\(missingFields.joined(separator: ", "))"
            
            toastie = Toastie(type: .error, title: errorTitle, message: errorSubTitle)
            return
        }
        
        if order == nil {
            print("📝 [OrderDetailView] Creating new order")
        } else {
            print("✏️ [OrderDetailView] Editing existing order")
        }

        if let existingOrder = order {
            print("💾 [OrderDetailView] Saving existing order changes:")
            print("  - Order ID: \(existingOrder.id)")
            print("  - Current state values:")
            print("    - orderReference: '\(orderReference)'")
            print("    - shippingCost: \(shippingCost)")
            print("    - sellingFees: \(sellingFees)")
            print("    - additionalCosts: \(additionalCosts)")
            print("    - shippingCompany: '\(shippingCompany)'")
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
            existingOrder.orderReceivedDate = orderReceivedDate
            existingOrder.orderReference = orderReference.isEmpty ? nil : orderReference
            existingOrder.customerName = customerName.isEmpty ? nil : customerName
            existingOrder.status = status
            existingOrder.platform = platform
            
            // Update shipping and cost data
            existingOrder.shippingCost = shippingCost
            existingOrder.sellingFees = sellingFees
            existingOrder.additionalCosts = additionalCosts
            existingOrder.shippingCompany = shippingCompany.isEmpty ? nil : shippingCompany
            existingOrder.shippingMethod = shippingMethod.isEmpty ? nil : shippingMethod
            existingOrder.trackingReference = trackingReference.isEmpty ? nil : trackingReference
            existingOrder.customerShippingCharge = customerShippingCharge
            existingOrder.additionalCostNotes = additionalCostNotes.isEmpty ? nil : additionalCostNotes
            existingOrder.deliveryMethod = deliveryMethod
            existingOrder.orderCompletionDate = orderCompletionDate
            
            // Handle reminder scheduling
            await handleReminderScheduling(for: existingOrder)
            
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
            print("  - existingOrder.shippingCompany: '\(existingOrder.shippingCompany ?? "nil")'")
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
            
            // Handle stock changes using StockManager
            if let stockManager = stockManager {
                // For existing orders, calculate stock adjustments by comparing old vs new quantities
                var stockAdjustments: [StockItem.ID: Int] = [:]
                
                // Count old quantities (restore to stock)
                for item in existingOrder.items {
                    if let stockItem = item.stockItem {
                        stockAdjustments[stockItem.id, default: 0] += item.quantity
                    }
                }
                
                // Subtract new quantities (allocate from stock)
                for orderItemEntry in validOrderItems {
                    if let stockItem = orderItemEntry.stockItem {
                        stockAdjustments[stockItem.id, default: 0] -= orderItemEntry.quantity
                    }
                }
                
                // Apply stock adjustments (positive = return to stock, negative = remove from stock)
                for (stockItemId, adjustment) in stockAdjustments {
                    if let stockItem = stockItems.first(where: { $0.id == stockItemId }) {
                        print("📦 [Stock Update via StockManager] Item: \(stockItem.name)")
                        print("  - Old quantity: \(stockItem.quantityAvailable)")
                        print("  - Adjustment: \(adjustment)")
                        do {
                            try stockManager.updateStockForOrderChange(
                                stockItem: stockItem,
                                oldQuantity: 0,
                                newQuantity: -adjustment  // Negative because we want to apply the adjustment
                            )
                            print("  - New quantity: \(stockItem.quantityAvailable)")
                        } catch {
                            print("❌ [Stock Update] Failed to update stock for \(stockItem.name): \(error)")
                        }
                    }
                }
                
                // Clear any pending changes since we've handled them manually
                stockManager.clearPendingChanges()
            }
            
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
                orderReceivedDate: orderReceivedDate,
                orderReference: orderReference.isEmpty ? nil : orderReference,
                customerName: customerName.isEmpty ? nil : customerName,
                status: status,
                platform: platform,
                items: [],
                shippingCost: shippingCost,
                sellingFees: sellingFees,
                additionalCosts: additionalCosts,
                shippingCompany: shippingCompany.isEmpty ? nil : shippingCompany,
                shippingMethod: shippingMethod.isEmpty ? nil : shippingMethod,
                trackingReference: trackingReference.isEmpty ? nil : trackingReference,
                customerShippingCharge: customerShippingCharge,
                additionalCostNotes: additionalCostNotes.isEmpty ? nil : additionalCostNotes,
                orderCompletionDate: orderCompletionDate,
                deliveryMethod: deliveryMethod,
                reminderEnabled: reminderEnabled, reminderTimeBeforeCompletion: reminderTimePeriod.timeInterval, attributes: attributesToSave
            )
            
            // Add order items
            for orderItemEntry in validOrderItems {
                let orderItem = OrderItem(quantity: orderItemEntry.quantity, stockItem: orderItemEntry.stockItem)
                orderItem.order = newOrder
                newOrder.items.append(orderItem)
            }
            
            // Commit pending stock changes using StockManager
            if let stockManager = stockManager {
                do {
                    try stockManager.commitPendingChanges()
                    print("📦 [New Order] Successfully committed stock changes via StockManager")
                } catch {
                    print("❌ [New Order] Failed to commit stock changes: \(error)")
                }
            }
            
            // Handle reminder scheduling for new order
            
            await handleReminderScheduling(for: newOrder)
            
            // Calculate and set revenue and profit automatically
            newOrder.revenue = newOrder.itemsTotal + newOrder.customerShippingCharge
            newOrder.profit = newOrder.calculatedProfit
            
            modelContext.insert(newOrder)
        }
        
        // Save changes to context
        do {
            try modelContext.save()
            print("✅ [OrderDetailView] Save completed successfully")
            
            // Verify stock quantities after save
            print("📦 [Post-Save Stock Check]")
            for stockItem in stockItems {
                print("  - \(stockItem.name): \(stockItem.quantityAvailable) units")
            }
            
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
            
          
    
         
           
                    dismissWithCleanup()
                
            
      
        } catch {
            print("❌ [OrderDetailView] Failed to save order: \(error)")
         
        }
    }
}

#Preview {
    OrderDetailView(mode: .add)
}

