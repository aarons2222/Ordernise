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
    @AppStorage("userTintHex") private var tintHex: String = "#007AFF" // default blue
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
                
                
                ScrollView() {
                    
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
                                            localeManager.setCurrency(currency)
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
                        
                        
                        
                        
                        CustomCardView("App Settings") {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("App Tint")
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    Text("Pick a color to customise the app’s look.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                ColorPicker("", selection: Binding(
                                    get: { Color(hex: tintHex) ?? .color1 },
                                    set: { color in
                                        tintHex = color.toHex()
                                    }
                                ))
                                .labelsHidden()
                            }
                        }
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











