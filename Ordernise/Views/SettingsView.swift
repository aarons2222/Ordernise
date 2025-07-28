//
//  SettingsView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedCurrency") private var selectedCurrency: String = {
        let localeCurrencyID = Locale.current.currency?.identifier ?? "GBP"
        return localeCurrencyID.uppercased()
    }()
    
    var selectedCurrencyEnum: Currency {
        Currency(rawValue: selectedCurrency) ?? .gbp
    }
    
    var body: some View {
        VStack {
            HeaderWithButton(
                title: "Settings",
                buttonImage: "line.3.horizontal.decrease.circle",
                showButton: true
            ) {
                print("Settings action")
            }
            
            Form {
                Section("General") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Currency")
                            .font(.headline)
                        Text("This currency will be used for new stock items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
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
                    .padding(.vertical, 4)
                }
            }
            
            Spacer()
        }
    }
    
    private func currencyDisplayName(for currency: Currency) -> String {
        switch currency {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
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
