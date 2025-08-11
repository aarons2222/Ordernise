//
//  ContentView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI


enum AppTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case orders = "Orders"
    case stock = "Stock"
    case settings = "settings"
    
    var symbolImage: String{
        switch self {
            case .dashboard:
            return "chart.bar.xaxis"
        case .orders:
            return "list.bullet.rectangle.portrait"
        case .stock:
            return "storefront"
        case .settings:
            return "gearshape"
        }
    }
    
}

struct ContentView: View {
    @State private var activeTab: AppTab = .dashboard
    @State private var searchText: String = ""
    @State private var isKeyboardVisible: Bool = false
    @State private var showSplash = true

    private let selectedTabKey = "selectedTab"

    init() {
        // Load the saved tab from UserDefaults
        if let savedTab = UserDefaults.standard.string(forKey: selectedTabKey),
           let tab = AppTab(rawValue: savedTab) {
            _activeTab = State(initialValue: tab)
        }
    }

    var body: some View {
        
  
            
            ZStack(alignment: .bottom) {
                // Main content
                VStack {
                    switch activeTab {
                    case .dashboard:
                        DashboardView()
                    case .orders:
                        OrderList(searchText: $searchText)
                    case .stock:
                        StockList(searchText: $searchText)
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(showSplash ? 0 : 1)
                
                // Tab bar overlay
                CustomTabBar(
                    activeTab: $activeTab,
                    searchText: $searchText,
                    onSearchBarExpanded: { isExpanded in
                        // Optional: respond to search bar expand/collapse
                    },
                    onSearchTextFieldActive: { isActive in
                        isKeyboardVisible = isActive
                    }
                )
                .opacity(showSplash ? 0 : 1)
                
                if showSplash {
                    SplashScreen(isActive: $showSplash)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            
            }
        
            
       
      
        .safeAreaInset(edge: .bottom) {
            // This creates proper spacing for the tab bar
            Color.clear.frame(height: isKeyboardVisible ? 0 : 10)
        }

        .onChange(of: activeTab) {
            // Save tab to UserDefaults
            UserDefaults.standard.set(activeTab.rawValue, forKey: selectedTabKey)
        }
    }
}


#Preview {
    ContentView()
}




struct SplashScreen: View {
    @Binding var isActive: Bool
    @Environment(\.colorScheme) var colorScheme

    // States for separate animations
    @State private var scale = 0.7
    @State private var opacity = 0.0
    
    // Pre-load and cache image
    private var logoImage: Image {
        colorScheme == .dark
            ? Image("LogoDark")
            : Image("Logo")
    }
    
    // Gradient that adapts to dark/light mode
    private var gradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.85),
                    Color.gray.opacity(0.5),
                    Color.gray.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.color1.opacity(0.4),
                    Color.color2.opacity(0.2),
                    Color.white.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        ZStack {
            gradient
                .ignoresSafeArea()
                .drawingGroup()
            
            
            VStack(spacing: 0){
                logoImage
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .drawingGroup()
                
                Text("Ordernise")
                    .font(Font.largeTitle.weight(.light))
                    
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                opacity = 1.0
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = false
                }
            }
        }
    }
}


