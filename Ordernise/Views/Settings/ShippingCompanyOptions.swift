//
//  ShippingCompanyOptions.swift
//  Ordernise
//
//  Created by Aaron Strickland on 18/08/2025.
//

import SwiftUI

struct ShippingCompanyOptions: View {
    
    
    private func getIcon(for company: ShippingCompany) -> Image {
        switch company {
        case .royalMail:
            return Image("royalmail")
        case .evri:
            return Image("evri")
        case .yodel:
            return Image("yodel")
        case .dpd:
            return Image("dpd")
        case .dhl:
            return Image("dhl")
        case .ups:
            return Image("ups")
        case .fedex:
            return Image("fedex")
        case .postNL:
            return Image("postnl")
        case .laPoste:
            return Image("laposte")
        case .deutschePost:
            return Image("deutschepost")
        case .usps:
            return Image("usps")
        case .canadaPost:
            return Image("canadapost")
    
        case .custom:
            return Image(systemName: "wrench.adjustable")
        }
    }
    
    
    
    
    // Shipping Company Settings - Default to all enabled
    @AppStorage("enabledShippingCompanies") private var enabledShippingCompaniesData: Data = {
        let defaultCompanies = ShippingCompany.allCases.map { $0.rawValue }
        return (try? JSONEncoder().encode(defaultCompanies)) ?? Data()
    }()
    
    var enabledShippingCompanies: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: enabledShippingCompaniesData)) ?? ShippingCompany.allCases.map { $0.rawValue }
        }
        set {
            enabledShippingCompaniesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func isShippingCompanyEnabled(_ company: ShippingCompany) -> Bool {
        enabledShippingCompanies.contains(company.rawValue)
    }
    
    func toggleShippingCompany(_ company: ShippingCompany) {
        var currentCompanies = enabledShippingCompanies
        if currentCompanies.contains(company.rawValue) {
            // Don't allow disabling all companies - must have at least one
            if currentCompanies.count > 1 {
                currentCompanies.removeAll { $0 == company.rawValue }
            }
        } else {
            currentCompanies.append(company.rawValue)
        }
        enabledShippingCompaniesData = (try? JSONEncoder().encode(currentCompanies)) ?? Data()
    }
    
    var body: some View {
        VStack {
            HeaderWithButton(
                title: String(localized: "Shipping Company Options"),
                buttonContent: "plus.circle",
                isButtonImage: false,
                showTrailingButton: false,
                showLeadingButton: true,
                onButtonTap: {
                    // Future: Add custom shipping company functionality
                }
            )
            
            ScrollView {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "Choose which shipping companies are available in your workflow"))
                                .font(.headline)
                             
                            Text(String(localized: "At least one shipping company must remain enabled"))
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 4)
                        
                        Spacer()
                    }
                    
                    ForEach(ShippingCompany.allCases.indices, id: \.self) { index in
                        let company = ShippingCompany.allCases[index]
                        
                        VStack(spacing: 0) {
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { isShippingCompanyEnabled(company) },
                                    set: { _ in toggleShippingCompany(company) }
                                )) {
                                    
                                    
                                 
                                    
                                    
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        
                                        HStack(spacing: 10){
                                            getIcon(for: company)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32, height: 32)
                                                .cornerRadius(8)
                                            
                                            Text(company.rawValue)
                                                .font(.headline)
                                        }
                                        Text(shippingCompanyDescription(for: company))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .tint(Color.appTint)
                                .disabled(enabledShippingCompanies.count == 1 && isShippingCompanyEnabled(company))
                                .padding(.horizontal, 0)
                                .padding(.vertical)
                            }
                            
                            // Show divider only if not the last item
                            if index < ShippingCompany.allCases.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .cardBackground()
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 60)
            .padding(.horizontal, 20)
        }
        .toolbar(.hidden)
    }
    
    private func shippingCompanyDescription(for company: ShippingCompany) -> String {
        switch company {
        case .royalMail: return String(localized: "UK postal service")
        case .evri: return String(localized: "UK parcel delivery service")
        case .yodel: return String(localized: "UK delivery network")
        case .dpd: return String(localized: "European parcel delivery")
        case .dhl: return String(localized: "International express delivery")
        case .ups: return String(localized: "Global shipping and logistics")
        case .fedex: return String(localized: "International courier service")
        case .postNL: return String(localized: "Netherlands postal service")
        case .laPoste: return String(localized: "French postal service")
        case .deutschePost: return String(localized: "German postal service")
        case .usps: return String(localized: "US postal service")
        case .canadaPost: return String(localized: "Canadian postal service")
        case .custom: return String(localized: "Custom shipping company or other")
        }
    }
}

// MARK: - Shipping Company Visibility Utility
extension ShippingCompany {
    static var enabledShippingCompanies: [ShippingCompany] {
        let enabledCompaniesData = UserDefaults.standard.data(forKey: "enabledShippingCompanies") ?? {
            let defaultCompanies = ShippingCompany.allCases.map { $0.rawValue }
            return (try? JSONEncoder().encode(defaultCompanies)) ?? Data()
        }()
        
        let enabledCompanyStrings = (try? JSONDecoder().decode([String].self, from: enabledCompaniesData)) ?? ShippingCompany.allCases.map { $0.rawValue }
        
        return ShippingCompany.allCases.filter { enabledCompanyStrings.contains($0.rawValue) }
    }
}

#Preview {
    ShippingCompanyOptions()
}
