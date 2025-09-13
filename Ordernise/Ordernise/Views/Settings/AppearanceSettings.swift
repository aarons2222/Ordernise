//
//  Appearance.swift
//  Ordernise
//
//  Created by Aaron Strickland on 31/08/2025.
//

import SwiftUI

struct AppearanceSettings: View {
    
    
    @AppStorage("AppTheme") private var appTheme: AppTheme = .light
    @AppStorage("userTintHex") private var tintHex: String = "#ACCDFF"
    @State private var selectedColor: Color = .color1
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack {
            
            
            
            HeaderWithButton(
                title: String(localized: "Appearance", table: "Appearance"),
                buttonContent: "line.3.horizontal.decrease.circle",
                isButtonImage: true,
                showTrailingButton: false,
                showLeadingButton: true,
                onButtonTap: {
                    
                    
                }
            )
            
            
            
            
            VStack(alignment: .leading){
          
                
                
                 
                
                
                CustomCardView {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "App Theme", table: "Settings"))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        
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
                                .foregroundColor(.primary)
                            
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
            .padding(.top, 15)
            .padding(.horizontal, 20)
            
            
            Spacer()
            
        }
        .environment(\.colorScheme, appTheme == .dark ? .dark : appTheme == .light ? .light : colorScheme)
        .background(
            appTheme == .dark ? Color.black : 
            appTheme == .light ? Color.white : 
            Color(.systemBackground)
        )
        .animation(.easeInOut(duration: 0.3), value: appTheme)
        .animation(.easeInOut(duration: 0.3), value: colorScheme)
        .id("\(appTheme.rawValue)_\(colorScheme)")
        .onAppear {
                    selectedColor = Color(hex: tintHex) ?? .color1
                }
        .toolbar(.hidden)
    }
}

#Preview {
    AppearanceSettings()
}
