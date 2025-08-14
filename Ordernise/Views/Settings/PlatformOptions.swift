//
//  PlatformOptions.swift
//  Ordernise
//
//  Created by Aaron Strickland on 10/08/2025.
//

import SwiftUI

struct PlatformOptions: View {
    
    // Platform Settings - Default to all enabled
    @AppStorage("enabledPlatforms") private var enabledPlatformsData: Data = {
        let defaultPlatforms = Platform.allCases.map { $0.rawValue }
        return (try? JSONEncoder().encode(defaultPlatforms)) ?? Data()
    }()
    
    var enabledPlatforms: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: enabledPlatformsData)) ?? Platform.allCases.map { $0.rawValue }
        }
        set {
            enabledPlatformsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func isPlatformEnabled(_ platform: Platform) -> Bool {
        enabledPlatforms.contains(platform.rawValue)
    }
    
    func togglePlatform(_ platform: Platform) {
        var currentPlatforms = enabledPlatforms
        if currentPlatforms.contains(platform.rawValue) {
            // Don't allow disabling all platforms - must have at least one
            if currentPlatforms.count > 1 {
                currentPlatforms.removeAll { $0 == platform.rawValue }
            }
        } else {
            currentPlatforms.append(platform.rawValue)
        }
        enabledPlatformsData = (try? JSONEncoder().encode(currentPlatforms)) ?? Data()
    }
    
    var body: some View {
        VStack {
            HeaderWithButton(
                title: String(localized: "Platform Options"),
                buttonContent: "plus.circle",
                isButtonImage: false,
                showTrailingButton: false,
                showLeadingButton: true,
                onButtonTap: {
                    // Future: Add custom platform functionality
                }
            )
            
            ScrollView {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "Choose which platforms are available in your workflow"))
                                .font(.headline)
                             
                            Text(String(localized: "At least one platform must remain enabled"))
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 4)
                        
                        Spacer()
                    }
                    
                    ForEach(Platform.allCases.indices, id: \.self) { index in
                        let platform = Platform.allCases[index]
                        
                        VStack(spacing: 0) {
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { isPlatformEnabled(platform) },
                                    set: { _ in togglePlatform(platform) }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(platform.rawValue)
                                            .font(.headline)
                                        Text(platformDescription(for: platform))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .tint(Color.appTint)
                                .disabled(enabledPlatforms.count == 1 && isPlatformEnabled(platform))
                                .padding(.horizontal, 0)
                                .padding(.vertical)
                            }
                            
                            // Show divider only if not the last item
                            if index < Platform.allCases.count - 1 {
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
        .navigationBarHidden(true)
    }
    
    private func platformDescription(for platform: Platform) -> String {
        switch platform {
        case .ebay: return String(localized: "Online auction and marketplace")
        case .vinted: return String(localized: "Second-hand fashion marketplace")
        case .shopify: return String(localized: "E-commerce platform")
        case .etsy: return String(localized: "Handmade and vintage marketplace")
        case .amazon: return String(localized: "Global e-commerce platform")
        case .depop: return String(localized: "Social shopping app")
        case .poshmark: return String(localized: "Fashion marketplace")
        case .carboot: return String(localized: "Car boot sales and local markets")
        case .marketplace: return String(localized: "Facebook marketplace")
        case .gumtree: return String(localized: "Local classified ads")
        case .custom: return String(localized: "Custom platform or other")
        }
    }
}



// MARK: - Platform Visibility Utility
extension Platform {
    static var enabledPlatforms: [Platform] {
        let enabledPlatformsData = UserDefaults.standard.data(forKey: "enabledPlatforms") ?? {
            let defaultPlatforms = Platform.allCases.map { $0.rawValue }
            return (try? JSONEncoder().encode(defaultPlatforms)) ?? Data()
        }()
        
        let enabledPlatformStrings = (try? JSONDecoder().decode([String].self, from: enabledPlatformsData)) ?? Platform.allCases.map { $0.rawValue }
        
        return Platform.allCases.filter { enabledPlatformStrings.contains($0.rawValue) }
    }
}

#Preview {
    PlatformOptions()
}
