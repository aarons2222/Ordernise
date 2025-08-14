//
//  LocaleManager.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//

import SwiftUI
import Foundation
internal import Combine

// MARK: - Supporting Types
enum SupportedLocale: String, CaseIterable {
    case enUS = "en-US"       // English (United States)
    case enGB = "en-GB"       // English (United Kingdom)
    case esES = "es-ES"       // Spanish (Spain)
    case frFR = "fr-FR"       // French (France)
    case deDE = "de-DE"       // German (Germany)
    case itIT = "it-IT"       // Italian (Italy)
    case jaJP = "ja-JP"       // Japanese (Japan)
    case zhCN = "zh-CN"       // Simplified Chinese (China)
    case nlNL = "nl-NL"       // Dutch (Netherlands)
    case plPL = "pl-PL"       // Polish (Poland)
    case trTR = "tr-TR"       // Turkish (Turkey)
    case svSE = "sv-SE"       // Swedish (Sweden)
    
    
    

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var languageCode: String {
        locale.language.languageCode?.identifier ?? ""
    }

    var regionCode: String {
        locale.region?.identifier ?? ""
    }

    var displayName: String {
        locale.localizedString(forIdentifier: rawValue) ?? rawValue
    }

    var currencySymbolName: String {
        switch self {
        case .enUS:
            return "dollarsign.circle"
        case .enGB:
            return "sterlingsign.circle"
        case .esES, .frFR, .deDE, .itIT, .nlNL, .svSE:
            return "eurosign.circle"
        case .plPL:
            return "polishzlotysign.circle"

        case .jaJP:
            return "yensign.circle"
        case .zhCN:
            return "chineseyuanrenminbisign.circle"
        case .trTR:
            return "turkishlirasign.circle"
        }
    }
    
    var currencyDisplayName: String {
        switch self {
        case .enUS:
            return  String(localized: "US Dollar")
        case .enGB:
            return String(localized: "British Pound")
        case .esES, .frFR, .deDE, .itIT, .nlNL, .svSE:
            return String(localized: "Euro")
        case .plPL:
            return String(localized: "Polish Złoty")
  
        case .jaJP:
            return String(localized: "Japanese Yen")
        case .zhCN:
            return String(localized: "Chinese Yuan")
        case .trTR:
            return String(localized: "Turkish Lira")
        }
    }
    
   
    
    
    
    
    
    
    
    
    
    
    
    var currencySymbol: String {
        switch self {
        case .enUS:
            return "$"
        case .enGB:
            return "£"
        case .esES, .frFR, .deDE, .itIT, .nlNL, .svSE:
            return "€"
        case .plPL:
            return "zł"
        case .jaJP:
            return "¥"
        case .zhCN:
            return "¥"
        case .trTR:
            return "₺"
        }
    }
}

class LocaleManager: ObservableObject {
    nonisolated static let shared = LocaleManager()
    
    // MARK: - Published Properties
    @Published var currentCurrency: Currency
    @Published var currentLocale: SupportedLocale
    
    // MARK: - AppStorage Properties
    @AppStorage("selectedCurrency") private var selectedCurrency: String = {
        let localeCurrencyID = Locale.current.currency?.identifier ?? "GBP"
        return localeCurrencyID.uppercased()
    }()
    
    @AppStorage("selectedLocale") private var selectedLocaleRawValue: String = {
        let currentLocaleID = Locale.current.identifier
        // Try to match current system locale to supported locales
        if let supportedLocale = SupportedLocale.allCases.first(where: { $0.rawValue == currentLocaleID }) {
            return supportedLocale.rawValue
        }
        // Default to UK English
        return SupportedLocale.enGB.rawValue
    }()
    
    // MARK: - Initialization
    private init() {
        // Initialize with defaults first
        self.currentCurrency = .gbp
        self.currentLocale = .enGB
        
        // Then update from stored values after initialization is complete
        self.updateFromStoredValues()
        
        // Set up observers to sync AppStorage changes with Published properties
        self.setupAppStorageObservers()
    }
    
    private func updateFromStoredValues() {
        // Update current currency from stored value
        self.currentCurrency = Currency(rawValue: selectedCurrency) ?? .gbp
        
        // Update current locale from stored value
        self.currentLocale = SupportedLocale(rawValue: selectedLocaleRawValue) ?? .enGB
    }
    
    private func setupAppStorageObservers() {
        // Create a publisher for selectedCurrency changes
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in UserDefaults.standard.string(forKey: "selectedCurrency") ?? "GBP" }
            .removeDuplicates()
            .compactMap { Currency(rawValue: $0) }
            .assign(to: &$currentCurrency)
        
        // Create a publisher for selectedLocale changes
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in UserDefaults.standard.string(forKey: "selectedLocale") ?? SupportedLocale.enGB.rawValue }
            .removeDuplicates()
            .compactMap { SupportedLocale(rawValue: $0) }
            .assign(to: &$currentLocale)
    }
    
    // MARK: - Currency Management
    
    /// Updates the current currency and saves to persistent storage
    @MainActor
    func setCurrency(_ currency: Currency) {
        currentCurrency = currency
        selectedCurrency = currency.rawValue
    }
    
    /// Gets the display name for the current currency
    var currencyDisplayName: String {
        getCurrencyDisplayName(for: currentCurrency)
    }
    
    /// Gets the display name for a specific currency
    func getCurrencyDisplayName(for currency: Currency) -> String {
        // Map Currency to SupportedLocale and use its currencyDisplayName when available
        switch currency {
        case .usd: return SupportedLocale.enUS.currencyDisplayName
        case .gbp: return SupportedLocale.enGB.currencyDisplayName
        case .eur: return SupportedLocale.esES.currencyDisplayName
        case .jpy: return SupportedLocale.jaJP.currencyDisplayName
        case .cny: return SupportedLocale.zhCN.currencyDisplayName
        case .pln: return SupportedLocale.plPL.currencyDisplayName
        case .aud: return String(localized: "Australian Dollar")
        case .cad: return String(localized: "Canadian Dollar")
        case .chf: return String(localized: "Swiss Franc")
        }
    }
    
    
    
    

    
    /// Gets the currency symbol name for SF Symbols
    var currencySymbolName: String {
        getCurrencySymbolName(for: currentCurrency)
    }
    
    /// Gets the currency symbol as a string (e.g., "$", "£", "€")
    var currencySymbol: String {
        getCurrencySymbol(for: currentCurrency)
    }
    
    /// Gets the currency symbol as text for the currently selected currency
    func getCurrencySymbolAsText() -> String {
        return getCurrencySymbol(for: currentCurrency)
    }
    
    /// Gets the currency symbol name for a specific currency
    func getCurrencySymbolName(for currency: Currency) -> String {
        // Map Currency to SupportedLocale when available, otherwise provide defaults
        switch currency {
        case .usd: return SupportedLocale.enUS.currencySymbolName
        case .gbp: return SupportedLocale.enGB.currencySymbolName
        case .eur: return SupportedLocale.esES.currencySymbolName
        case .jpy: return SupportedLocale.jaJP.currencySymbolName
        case .cny: return SupportedLocale.zhCN.currencySymbolName
        case .pln: return SupportedLocale.plPL.currencySymbolName
        case .aud: return "dollarsign.circle"
        case .cad: return "dollarsign.circle"
        case .chf: return "francsign.circle"
        }
    }
    
    /// Gets the currency symbol as a string for a specific currency
    func getCurrencySymbol(for currency: Currency) -> String {
        // Map Currency to SupportedLocale when available, otherwise provide defaults
        switch currency {
        case .usd: return SupportedLocale.enUS.currencySymbol
        case .gbp: return SupportedLocale.enGB.currencySymbol
        case .eur: return SupportedLocale.esES.currencySymbol
        case .jpy: return SupportedLocale.jaJP.currencySymbol
        case .cny: return SupportedLocale.zhCN.currencySymbol
        case .pln: return SupportedLocale.plPL.currencySymbol
        case .aud: return "A$"
        case .cad: return "C$"
        case .chf: return "CHF"
        }
    }
    
    /// Gets the currency format style for formatting numbers
    var currencyFormatStyle: FloatingPointFormatStyle<Double>.Currency {
        FloatingPointFormatStyle<Double>.Currency(code: currentCurrency.rawValue)
    }
    
    /// Gets currency format style for a specific currency
    func getCurrencyFormatStyle(for currency: Currency) -> FloatingPointFormatStyle<Double>.Currency {
        FloatingPointFormatStyle<Double>.Currency(code: currency.rawValue)
    }
    
    // MARK: - Locale Management
    
    /// Updates the current locale and saves to persistent storage
    @MainActor
    func setLocale(_ locale: SupportedLocale) {
        currentLocale = locale
        selectedLocaleRawValue = locale.rawValue
        
        // Optionally update currency based on locale
        // updateCurrencyForLocale(locale)
    }
    
    /// Gets the display name for the current locale
    var localeDisplayName: String {
        currentLocale.displayName
    }
    
    /// Gets the display name for a specific locale
    func getLocaleDisplayName(for locale: SupportedLocale) -> String {
        locale.displayName
    }
    
    // MARK: - Helper Methods
    
    /// Updates currency based on locale (future feature)
    private func updateCurrencyForLocale(_ locale: SupportedLocale) {
        let newCurrency: Currency
        
        switch locale {
        case .enUS:
            newCurrency = .usd
        case .enGB:
            newCurrency = .gbp
        case .esES, .frFR, .deDE, .itIT, .nlNL, .svSE:
            newCurrency = .eur
        case .plPL:
            newCurrency = .pln
        case .jaJP:
            newCurrency = .jpy
        case .zhCN:
            newCurrency = .cny
        case .trTR:
            
            // These locales don't have corresponding currencies in our Currency enum
            // Keep current currency
            return
        }
        
        Task { @MainActor in
            currentCurrency = newCurrency
            selectedCurrency = newCurrency.rawValue
        }
    }
    
    /// Gets the best matching SupportedLocale for a given Currency
    func getSupportedLocale(for currency: Currency) -> SupportedLocale? {
        switch currency {
        case .usd: return .enUS
        case .gbp: return .enGB
        case .eur: return .esES  // Could be any Euro zone country
        case .jpy: return .jaJP
        case .cny: return .zhCN
        case .pln: return .plPL
        case .aud, .cad, .chf: return nil
        }
    }
    
    // MARK: - Future Language Support
    
    /// Placeholder for future localized string support
    func localizedString(for key: String) -> String {
        // Future implementation will return localized strings based on currentLocale
        // For now, return the key as placeholder
        return key
    }
    
    /// Gets the language code for the current locale
    var currentLanguageCode: String {
        currentLocale.languageCode
    }
    
    /// Gets the region code for the current locale
    var currentRegionCode: String {
        currentLocale.regionCode
    }
}

// MARK: - SwiftUI Environment Integration
extension EnvironmentValues {
    var localeManager: LocaleManager {
        get { LocaleManager.shared }
        set { /* Read-only */ }
    }
}
