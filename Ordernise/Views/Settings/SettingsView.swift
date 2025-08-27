//
//  SettingsView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @StateObject private var localeManager = LocaleManager.shared
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("userTintHex") private var tintHex: String = "#ACCDFF"
    @State private var selectedColor: Color = .color1
    
    @State private var showingSupport = false
    @State private var showingPaywall = false
    
    
    @AppStorage("AppTheme") private var appTheme: AppTheme = .systemDefault
 
    // Computed properties for subscription status display
    private var subscriptionStatusText: String {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed:
            return "Active"
        case .notSubscribed:
            return "Free"
        case .expired:
            return "Expired"
        case .pending:
            return "Pending"
        case .revoked:
            return "Revoked"
        case .unknown:
            return subscriptionManager.isLoading ? "Loading..." : "Unknown"
        }
    }
    
    private var subscriptionStatusColor: Color {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed:
            return .green
        case .notSubscribed:
            return .blue
        case .expired, .revoked:
            return .red
        case .pending:
            return .orange
        case .unknown:
            return .gray
        }
    }
    
    private var subscriptionStatusDescription: String {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed(_, let expirationDate):
            if let expirationDate = expirationDate {
                return "You have full access to all premium features until \(formatExpiryDate(expirationDate))"
            } else {
                return "You have full access to all premium features"
            }
        case .notSubscribed:
            return "Upgrade to unlock advanced features and unlimited usage"
        case .expired:
            return "Your subscription has expired. Renew to continue using premium features"
        case .pending:
            return "Your subscription is being processed"
        case .revoked:
            return "Your subscription has been cancelled"
        case .unknown:
            return "Checking subscription status..."
        }
    }
    
    private var subscriptionExpiryDate: Date? {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed(_, let expirationDate):
            return expirationDate
        default:
            return nil
        }
    }
    
    private func formatExpiryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    
    var body: some View {
        
        NavigationStack{
            
            
            VStack {
              
                
                
                HeaderWithButton(
                    title: String(localized: "Settings", table: "Settings"),
                    buttonContent: "line.3.horizontal.decrease.circle",
                    isButtonImage: true,
                    showTrailingButton: false,
                    showLeadingButton: false,
                    onButtonTap: {
                  
                        
                    }
                )
                
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 15) {
                        
                        VStack(alignment: .leading){
                         
                        
                    SectionHeader(title: String(localized: "General", table: "Settings"))
                          
                            
                            CustomCardView{
                                
                                
                                HStack{
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(String(localized: "Currency", table: "Settings"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text(String(localized: "This currency will be used for new stock items", table: "Settings"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        
                                    }
                                    Spacer()
                                    
                                    
                                    Menu {
                                        ForEach(Currency.allCases, id: \.rawValue) { currency in
                                            Button {
                                                localeManager.setCurrency(currency)
                                            } label: {
                                                HStack {
                                                    Image(systemName: localeManager.getCurrencySymbolName(for: currency))
                                                        .font(.title2)
                                                        .foregroundColor(.appTint)
                                                    
                                                    Text(" \(localeManager.getCurrencyDisplayName(for: currency))")
                                                        .font(.title2)
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            
                                            Image(systemName: localeManager.getCurrencySymbolName(for: localeManager.currentCurrency))
                                                .font(.title)
                                                .foregroundStyle(Color.appTint)
                                            
                                   
                                            
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.title3)
                                                .tint(Color.appTint)
                                        }
                                    }
                                    
                                }
                                
                                
                            }
                            .padding(.bottom, 3)
                            
                     
                        
                        
                        
                        
                        }
                        
                        
                        VStack(alignment: .leading){
                            
                            SectionHeader(title: String(localized: "Subscription"))
                            
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Subscription Status")
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Spacer()
                                            
                                            // Status badge
                                            Text(subscriptionStatusText)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(subscriptionStatusColor.opacity(0.2))
                                                .foregroundColor(subscriptionStatusColor)
                                                .cornerRadius(12)
                                        }
                                        
                                        Text(subscriptionStatusDescription)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                        
                                        // Show current product if subscribed
                                        if subscriptionManager.isSubscribed, let productId = subscriptionManager.currentProductId {
                                            Text("Plan: \(productId.replacingOccurrences(of: "_", with: " ").capitalized)")
                                                .font(.caption)
                                                .foregroundColor(.appTint)
                                                .fontWeight(.medium)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Action button or status icon
                                    if subscriptionManager.isSubscribed {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.green)
                                    } else {
                                        Button("Upgrade") {
                                            showingPaywall = true
                                        }
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.appTint)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        
                        VStack(alignment: .leading){
                     

                            SectionHeader(title: String(localized: "Workflow Settings"))
                            
                            
                            
                            NavigationLink(destination: OrderStatusOptions()) {
                                
                                CustomCardView(String(localized: "Order Settings", table: "Settings")) {
                                    
                                    HStack(alignment: .center){
                                        
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Order Status Options", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            
                                            
                                            Text(String(localized: "Select which statuses are available in your order workflow.", table: "Settings"))
                                            
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)
                                    }
                                    
                                }
                            }
                            
                            
                            
                            
                            NavigationLink(destination: PlatformOptions()) {
                                
                                CustomCardView {
                                    
                                    HStack{
                                        
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Platform Options", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            
                                            
                                            Text(String(localized: "Select which platforms are available in your order workflow.", table: "Settings"))
                                            
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                    
                                }.padding(.vertical, 3)
                            }
                            
                            
                            
                            
                            NavigationLink(destination: ShippingCompanyOptions()) {
                                
                                CustomCardView {
                                    
                                    HStack{
                                        
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Shipping Companies"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            
                                            
                                            Text(String(localized: "Select which shipping companies are available in your order workflow."))
                                            
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                    
                                }.padding(.vertical, 3)
                            }
                         
                            
                            NavigationLink(destination: CategoryOptions().enableSwipeBack()) {
                                CustomCardView{
                                    
                                    HStack{
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Categories", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Organise your stock items by category to keep things easy to find.", table: "Settings"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                }
                            }
                            
                        }
                        
                        
                        
                        
                        
                        
                       
                        
                   
                        
                 
                  
                        
                        VStack(alignment: .leading){
                         
                            
                            
                  

                            
                            SectionHeader(title: String(localized: "Form Fields", table: "Settings"))
                            
                            NavigationLink(destination: OrderFieldSettings()) {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Order Fields", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Customise which fields are shown when creating and editing orders", table: "Settings"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                }
                                .padding(.bottom, 3)
                            }
                        
                            
                            
                            
                            
                            NavigationLink(destination: StockFieldSettings()) {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Stock Fields", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Customise which fields are shown when creating and editing stock items.", table: "Settings"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                   
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        VStack(alignment: .leading){
                        
                            
                  
                            
                            SectionHeader(title: String(localized: "Data", table: "Settings"))
                            

                            
                            NavigationLink(destination: ExportDataView()) {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Export Data", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Export your orders and inventory data to Excel or CSV format for analysis and backup.", table: "Settings"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)
                                    }
                                }
                            }
                        }
                        
                        
                        VStack(alignment: .leading){
                      
                            
                            
                            SectionHeader(title: String(localized: "Appearance", table: "Settings"))
                             
                            
                            
                            CustomCardView {
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(localized: "App Theme", table: "Settings"))
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    
                                    Text(String(localized: "Pick your favorite theme, or let the app follow your device settings.", table: "Settings"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    SegmentedControl(
                                        tabs: AppTheme.allCases,
                                        activeTab: $appTheme,
                                        height: 35,
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
                                 
                                    .padding(.vertical)
                                    
                                    
                                    
                                    
//                                    
//                                    Picker("", selection: $appTheme){
//                                        
//                                        ForEach(AppTheme.allCases, id: \.rawValue){ theme in
//                                                    
//                                            Text(theme.rawValue)
//                                                .tag(theme)
//                                        }
//                                    }
//                                    .pickerStyle(.segmented)
                                    
                                    
                                    
                                }
                                
                            }
                            .padding(.bottom, 3)
                            
                            CustomCardView {
                                
                                
                                
                                
                                
                                
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(String(localized: "App Tint", table: "Settings"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text(String(localized: "Pick a color to customise the app's look - some colours may make some UI elements unreadable.", table: "Settings"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    ColorPicker("", selection: Binding(
                                        get: { Color(hex: tintHex) ?? .color1 },
                                        set: { color in
                                            DispatchQueue.main.async {
                                                tintHex = color.toHex()
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                }
                            }
                            
                            
                        }
                 
                        
                        
                        
                        VStack(alignment: .leading){
                      
                            SectionHeader(title: String(localized: "Testing", table: "Settings"))
                            
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                     
                                            Text(String(localized: "Dummy Mode", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                       
                                    
                                        
                                        Text(dummyDataManager.isDummyModeEnabled ?
                                            String(localized: "Using 100 test orders from the last year for demonstration purposes", table: "Settings") :
                                            String(localized: "Use realistic test data instead of your actual business data", table: "Settings"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                   
                                        Toggle("", isOn: $dummyDataManager.isDummyModeEnabled)
                                            .labelsHidden()
                                            .tint(Color.appTint)
                                        
                                  
                                    
                                }
                            }
                        }
                        
                        VStack(alignment: .leading){
                     
                            SectionHeader(title: String(localized: "Support", table: "Settings"))
                               

                            Button{
                                self.showingSupport = true
                            }label: {
                            
                    
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Support", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Get support here", table: "Settings"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)
                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                        
                        
                        Color.clear.frame(height: 60)
                    }
                    
                
            }
            .padding(.horizontal, 20)
  
        }
            
           .navigationBarHidden(true)
           .onAppear {
                       selectedColor = Color(hex: tintHex) ?? .color1
                   }
         
    }
        
     
            .fullScreenCover(isPresented: $showingSupport) {
                SupportView()
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
    }
    
    private func scheduleTestNotification() async {
        // Request permission first if needed
        let granted = await notificationManager.requestPermission()
        
        guard granted else {
            print("❌ Notification permission denied")
            return
        }
        
        // Schedule test notification in 1 minute
        let testDate = Date().addingTimeInterval(60) // 1 minute from now
        
        let notificationId = await notificationManager.scheduleOrderCompletionReminder(
            orderId: UUID(),
            orderReference: "TEST-001",
            customerName: "Test Customer",
            completionDate: testDate,
            timeBeforeCompletion: 0 // No offset, notification at exact time
        )
        
        if notificationId != nil {
            print("✅ Test notification scheduled for 1 minute from now")
        } else {
            print("❌ Failed to schedule test notification")
        }
    }
    


    

}

#Preview {
    SettingsView()
}













struct SwipeBackEnabledView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            if let navController = controller.navigationController {
                navController.interactivePopGestureRecognizer?.isEnabled = true
                navController.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension View {
    func enableSwipeBack() -> some View {
        self.background(SwipeBackEnabledView().frame(width: 0, height: 0))
    }
}
