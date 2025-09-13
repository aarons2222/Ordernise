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
    
    
    @AppStorage("AppTheme") private var appTheme: AppTheme = .light
    @Environment(\.colorScheme) var colorScheme
    
    
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
        ThemeSwitcher {
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
                                        
                                        
                                        
                                        
                                        if let productId = subscriptionManager.currentProductId {
                                            
                                            
                                            
                                            SettingsCardRow(title: "Subscription Status", subtitle:  "Current Plan: \(displayName(for: productId))\n\(subscriptionStatusDescription)")
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
                                    
                                    SettingsCardRow(title: "Workflow", subtitle:  "Statuses, platforms, shipping, categories.")
                                    
                                }
                                
                                
                                NavigationLink {
                                    FormFieldSettings()
                                } label: {
                                    
                                    SettingsCardRow(title: "Form Fields", subtitle:  "Customise which fields are shown for orders and stock items.")
                                }
                            }.padding(.top, 15)
                            
                            NavigationLink {
                                AppearanceSettings()
                            } label: {
                                
                                
                                SettingsCardRow(title: "Appearance", subtitle:  "Customize how Ordernise looks and feels.")
                                
                                
                                
                                
                            }
                            .padding(.top, 15)
                            
                            
                            
                            VStack(alignment: .leading){
                                
                                
                                
                                
                                
                                
                                NavigationLink(destination: ExportDataView()) {
                                    
                                    SettingsCardRow(title: "Export Data", subtitle:  "Export your data to CSV format.")
                                    
                                    
                                }
                                
                                // Erase All Data
                                Button(action: {
                                    showingEraseDataAlert = true
                                }) {
                                    
                                    SettingsCardRow(title: "Erase All Data", subtitle:  "Permanently delete all data. This cannot be undone.", iconColor: .red, trailingImage: "trash.circle")
                                    
                                }
                            }
                            
                            
                            NavigationLink {
                                SupportView()
                            } label: {
                                
                                
                                SettingsCardRow(title: "Support & Legal", subtitle:  "Contact support, terms and conditions")
                                
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
                .background(appTheme == .dark ? Color.black : appTheme == .light ? Color.white : (colorScheme == .dark ? Color.black : Color.white))
                .onAppear {
                    selectedColor = Color(hex: tintHex) ?? .color1
                    
                    // Load subscription status during app launch
                    Task {
                        await subscriptionManager.loadProducts()
                    }
                }
                .sheet(isPresented: $showingPaywall) {
                    PaywallView()
                }
                .alert(String(localized: "Are you sure?", table: "Settings"), isPresented: $showingEraseDataAlert) {
                    Button(String(localized: "Cancel", table: "Settings"), role: .cancel) { }
                    Button(String(localized: "Erase", table: "Settings"), role: .destructive) {
                        showingFinalEraseConfirmation = true
                    }
                } message: {
                    Text(String(localized: "This will delete all orders and stock items permanently.", table: "Settings"))
                }
                .alert(String(localized: "Final warning", table: "Settings"), isPresented: $showingFinalEraseConfirmation) {
                    Button(String(localized: "Cancel", table: "Settings"), role: .cancel) { }
                    Button(String(localized: "Erase Everything", table: "Settings"), role: .destructive) {
                        eraseAllData()
                    }
                } message: {
                    Text(String(localized: "This action cannot be undone. All your data will be lost.", table: "Settings"))
                }
                .toolbar(.hidden)
            }
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





