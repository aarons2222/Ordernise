//
//  SettingsView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var localeManager = LocaleManager.shared
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("userTintHex") private var tintHex: String = "#ACCDFF"
    @State private var selectedColor: Color = .color1
    

    @State private var showingPaywall = false
    @State private var showingEraseDataAlert = false
    @State private var showingFinalEraseConfirmation = false
    
    
    @AppStorage("AppTheme") private var appTheme: AppTheme = .systemDefault
 

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
    
//    private var subscriptionStatusDescription: String {
//        switch subscriptionManager.subscriptionStatus {
//        case .subscribed(_, let expirationDate):
//            if let expirationDate = expirationDate {
//                return "You have unlimited access until \(formatExpiryDate(expirationDate))"
//            } else {
//                return "You have unlimited access"
//            }
//        case .notSubscribed:
//            return "Upgrade now for unlimited usage"
//        case .expired:
//            return "Your subscription has expired. Renew to regain unlimited access"
//        case .pending:
//            return "Your subscription is being processed"
//        case .revoked:
//            return "Your subscription has been cancelled"
//        case .unknown:
//            return "Checking subscription status..."
//        }
//    }

    
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

    private func displayName(for productId: String) -> String {
        switch productId {
        case "ordernisemonthly": return "Ordernise Monthly"
        case "orderniseannual": return "Ordernise Annual"
        default: return productId.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
    
    
    private var subscriptionStatusDescription: String {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed(_, let expirationDate):
            
            if let expirationDate = expirationDate {
                return "Expires: \(formatExpiryDate(expirationDate))."
            } else {
                return ""
            }
            
        case .notSubscribed:
            return "Upgrade anytime to remove limitations."
            
        case .expired:
            return "Your subscription has expired – resubscribe to continue enjoying premium features."
            
        case .pending:
            return "Your subscription is being processed… please wait."
            
        case .revoked:
            return "Your subscription was cancelled – upgrade again to regain full access."
            
        case .unknown:
            return "Checking your subscription status…"
        }
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
                            
                         
                            
                            if subscriptionManager.isSubscribed {
                                Button {
                                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    CustomCardView {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Text("Subscription Status")
                                                        .font(.headline)
                                                        .foregroundColor(.text)
                                                }
                                                
                                                
                                                if let productId = subscriptionManager.currentProductId {
                                                    Text("Current Plan: \(displayName(for: productId))\n\(subscriptionStatusDescription)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                        .multilineTextAlignment(.leading)
                                                }
                                                
                                                
                                                
                                                
                                                // Show current product if subscribed
                                                
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right.circle")
                                                .font(.title2)
                                                .tint(Color.appTint)
                                        }
                                    }
                                }
                            } else {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text("Free")
                                                    .font(.headline)
                                                    .foregroundColor(.text)
                                            }
                                            
                                            Text(subscriptionStatusDescription)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
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
                        .padding(.top, 15)
                        
                        
                        
                        
                        
                        
                        
                        VStack(alignment: .leading, spacing: 12) {
                 
                            SectionHeader(title: String(localized: "General", table: "Settings"))

                            // Currency
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(String(localized: "Currency", table: "Settings"))
                                            .font(.headline)
                                            .foregroundColor(.text)

                                        Text(String(localized: "Used for new stock items", table: "Settings"))
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
                                                    Text(localeManager.getCurrencyDisplayName(for: currency))
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
                                        // Helpful for VoiceOver since the label is icon-only
                                        .accessibilityLabel(Text(String(localized: "Change currency", table: "Settings")))
                                    }
                                }
                            }

                            // Dummy Mode
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(String(localized: "Dummy Mode", table: "Settings"))
                                            .font(.headline)
                                            .foregroundColor(.text)

                                        Text(dummyDataManager.isDummyModeEnabled
                                             ? String(localized: "Demo mode on — 100 orders.", table: "Settings")
                                             : String(localized: "Use demo mode.", table: "Settings"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    }
                                    Spacer()

                                    Toggle("", isOn: $dummyDataManager.isDummyModeEnabled)
                                        .labelsHidden()
                                        .tint(Color.appTint)
                                        .accessibilityLabel(Text(String(localized: "Dummy Mode", table: "Settings")))
                                        .accessibilityValue(Text(dummyDataManager.isDummyModeEnabled
                                                                 ? String(localized: "On", table: "Settings")
                                                                 : String(localized: "Off", table: "Settings")))
                                }
                            }
                        }
                        .padding(.top, 15)

                            
                            
                            
                        
                        
             
                        
                        
                        
                        VStack(alignment: .leading){
                 
                            SectionHeader(title: String(localized: "Customisation"))
                        
                        NavigationLink(destination: WorkflowSettings()) {
                            CustomCardView {
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(String(localized: "Workflow", table: "Settings"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text(String(localized: "Statuses, platforms, shipping, categories.", table: "Settings"))
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
                        
                        
                        NavigationLink {
                            FormFieldSettings()
                        } label: {
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(String(localized: "Form Fields", table: "Settings"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text(String(localized: "Customise which fields are shown for orders and stock items.", table: "Settings"))
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
                        
                        
                        
                        
                    }.padding(.top, 15)
                        
                        
                        
                        
                        
                        
                        
                        
                    
                        NavigationLink {
                            AppearanceSettings()
                        } label: {
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(String(localized: "Appearance", table: "Settings"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text(String(localized: "Customize how Ordernise looks and feels", table: "Settings"))
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
                        .padding(.top, 15)
                        
                   
              
                        VStack(alignment: .leading){
                        
                    
                  
                                                

                            
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
                            
                            // Erase All Data
                            Button(action: {
                                showingEraseDataAlert = true
                            }) {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Erase All Data", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.red)
                                            
                                            Text(String(localized: "Permanently delete all orders, stock items, and categories. This cannot be undone.", table: "Settings"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "trash.circle")
                                            .font(.title2)
                                            .tint(.red)
                                    }
                                }
                            }
                        }
                        
                   
                        
                        
                 
                   
                        
                        
                            NavigationLink {
                                SupportView()
                            } label: {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Support & Legal", table: "Settings"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Contact support, terms and conditions", table: "Settings"))

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
                        
                        
                        
                        HStack{
                            Spacer()
                            Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.6))
                            
                            Spacer()
                        
                        }
                        .padding(.top, 10)
                        
                        
                        Color.clear.frame(height: 60)
                    }
                    
                
            }
            .padding(.horizontal, 20)
  
        }
            
            .toolbar(.hidden)
           .onAppear {
                       selectedColor = Color(hex: tintHex) ?? .color1
                   }
         
    }
        
     
           
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
            .alert("Erase All Data", isPresented: $showingEraseDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showingFinalEraseConfirmation = true
                }
            } message: {
                Text("This will permanently delete all orders, stock items, categories, and other data from your device and iCloud. This action cannot be undone.")
            }
            .alert("Final Confirmation", isPresented: $showingFinalEraseConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Yes, Erase Everything", role: .destructive) {
                    eraseAllData()
                }
            } message: {
                Text("Are you absolutely sure? All data will be permanently deleted and cannot be recovered. This is your last chance to cancel.")
            }
    }
    
    private func eraseAllData() {
        do {
            // Clear all orders
            let orderDescriptor = FetchDescriptor<Order>()
            if let orders = try? modelContext.fetch(orderDescriptor) {
                for order in orders {
                    modelContext.delete(order)
                }
            }
            
            // Clear all stock items
            let stockDescriptor = FetchDescriptor<StockItem>()
            if let stockItems = try? modelContext.fetch(stockDescriptor) {
                for stockItem in stockItems {
                    modelContext.delete(stockItem)
                }
            }
            
            // Clear all categories
            let categoryDescriptor = FetchDescriptor<Category>()
            if let categories = try? modelContext.fetch(categoryDescriptor) {
                for category in categories {
                    modelContext.delete(category)
                }
            }
            
            // Save the context to persist deletions
            try modelContext.save()
            
            // Reset setup flags to allow fresh start
            UserDefaults.standard.set(false, forKey: "hasCompletedInitialSetup")
            
            // Disable dummy mode
            dummyDataManager.isDummyModeEnabled = false
            
            print("✅ All data erased successfully")
            
        } catch {
            print("❌ Failed to erase data: \(error)")
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
