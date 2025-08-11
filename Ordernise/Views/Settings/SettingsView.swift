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
    @AppStorage("userTintHex") private var tintHex: String = "#ACCDFF"
    @State private var selectedColor: Color = .color1
    
 
    
    var body: some View {
        
        NavigationStack{
            
            
            VStack {
              
                
                
                HeaderWithButton(
                    title: "Settings",
                    buttonContent: "line.3.horizontal.decrease.circle",
                    isButtonImage: true,
                    showTrailingButton: false,
                    showLeadingButton: false,
                    onButtonTap: {
                  
                        
                    }
                )
                
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 15) {
                        
                        
                        CustomCardView("General") {
                            
                            
                            HStack{
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Default Currency")
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    Text("This currency will be used for new stock items")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    
                                }
                                Spacer()
                                
                                Picker("Currency", selection: Binding(
                                    get: { localeManager.currentCurrency.rawValue },
                                    set: { newValue in
                                        if let currency = Currency(rawValue: newValue) {
                                            DispatchQueue.main.async {
                                                localeManager.setCurrency(currency)
                                            }
                                        }
                                    }
                                )) {
                                    ForEach(Currency.allCases, id: \.rawValue) { currency in
                                        Text("\(localeManager.getCurrencySymbol(for: currency)) \(localeManager.getCurrencyDisplayName(for: currency))")
                                            .tag(currency.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.appTint)
                            }
                            
                        
                            
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Dummy Mode")
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        if dummyDataManager.isDummyModeEnabled {
                                            Text("ON")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.orange)
                                                .foregroundColor(.white)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    
                                    Text(dummyDataManager.isDummyModeEnabled ? 
                                        "Using 100 test orders from the last year for demonstration purposes" : 
                                        "Use realistic test data instead of your actual business data")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 8) {
                                    Toggle("", isOn: $dummyDataManager.isDummyModeEnabled)
                                        .labelsHidden()
                                        .tint(Color.appTint)
                                    
                                    if dummyDataManager.isDummyModeEnabled {
                                        Button("Debug Refresh") {
                                            dummyDataManager.forceRefresh()
                                        }
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        NavigationLink(destination: OrderStatusOptions()) {
                            
                            CustomCardView("Order Settings") {
                                
                                HStack{
                                    
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Order Status Options")
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        
                                        
                                        Text("Select which statuses are available in your order workflow.")
                                        
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                        
                                    }
                                    
                                    Spacer()
                                }
                                
                            }
                        }
                        
                        NavigationLink(destination: PlatformOptions()) {
                            
                            CustomCardView {
                                
                                HStack{
                                    
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Platform Options")
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        
                                        
                                        Text("Select which platforms are available in your order workflow.")
                                        
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                        
                                    }
                                    
                                    Spacer()
                                }
                                
                            }
                        }
                        
                        NavigationLink(destination: OrderFieldSettings()) {
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Order Fields")
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text("Customize which fields are shown when creating and editing orders.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        NavigationLink(destination: StockFieldSettings()) {
                            CustomCardView {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Stock Fields")
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text("Customize which fields are shown when creating and editing stock items.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        NavigationLink(destination: CategoryOptions()) {
                            CustomCardView{
                                
                                HStack{
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Categories")
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text("Organise your stock items by category to keep things easy to find.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        NavigationLink(destination: SalesReportView()) {
                            CustomCardView("Sales Report") {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Sales Report")
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text("Generate comprehensive sales reports with revenue, profit, and performance metrics.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        CustomCardView("App Settings") {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("App Tint")
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    Text("Pick a color to customise the app’s look - some colours may make some UI elmenets unreadable.")
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
    }
    


    

}

#Preview {
    SettingsView()
}











