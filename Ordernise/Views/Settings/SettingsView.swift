//
//  SettingsView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @AppStorage("selectedCurrency") private var selectedCurrency: String = {
        let localeCurrencyID = Locale.current.currency?.identifier ?? "GBP"
        return localeCurrencyID.uppercased()
    }()
    

    
    
    
    

    
    var selectedCurrencyEnum: Currency {
        Currency(rawValue: selectedCurrency) ?? .gbp
    }
    
 
    
    var body: some View {
        
        NavigationStack{
            
            
            VStack {
                HeaderWithButton(
                    title: "Settings",
                    buttonImage: "line.3.horizontal.decrease.circle",
                    showTrailingButton: false,
                    showLeadingButton: false
                ) {
                    print("Settings action")
                }
                
                
                
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
                            
                            Picker("Currency", selection: $selectedCurrency) {
                                ForEach(Currency.allCases, id: \.rawValue) { currency in
                                    HStack {
                                        Text(currency.rawValue)
                                        Text(currencyDisplayName(for: currency))
                                            .foregroundColor(.secondary)
                                    }
                                    .tag(currency.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            
                            
                         
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
                    
                }
                    
                
            }
            .padding(.horizontal, 20)
  
        }
            
           .navigationBarHidden(true)
      
    }
    }
    

    private func currencyDisplayName(for currency: Currency) -> String {
        switch currency {
        case .gbp: return "British Pound"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .jpy: return "Japanese Yen"
        case .aud: return "Australian Dollar"
        case .cad: return "Canadian Dollar"
        case .chf: return "Swiss Franc"
        case .cny: return "Chinese Yuan"
        case .inr: return "Indian Rupee"
        }
    }
    

}

#Preview {
    SettingsView()
}
