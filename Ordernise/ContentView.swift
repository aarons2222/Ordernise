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
    @Environment(\.colorScheme) var colorScheme


    init() {
        // Load the saved tab from UserDefaults
        if let savedTab = UserDefaults.standard.string(forKey: selectedTabKey),
           let tab = AppTab(rawValue: savedTab) {
            _activeTab = State(initialValue: tab)
        }
        
    

    }
    @State private var showOnBoarding: Bool = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    private var logoImage: Image {
        colorScheme == .dark
            ? Image("LogoDark")
            : Image("Logo")
    }
    
    
    var body: some View {
        
        ThemeSwitcher{
            
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
                .sheet(isPresented: $showOnBoarding) {
                    OnBoardingView(tint: Color.appTint, title: "Welcome to Ordernise") {
                        /// App Icon
                        logoImage
                            .resizable()
                            .frame(width: 150, height: 150)
                       
                    } cards: {
                        /// Cards
                        OnBoardingCard(
                            symbol: "cube.box",
                            title: "Manage Your Inventory",
                            subTitle: "Track stock levels, organise items by category, and never run out of popular products."
                        )
                        
                        OnBoardingCard(
                            symbol: "doc.text.fill",
                            title: "Process Orders Efficiently",
                            subTitle: "Create orders, track shipping, manage customer details, and monitor completion dates."
                        )
                        
                        OnBoardingCard(
                            symbol: "chart.line.uptrend.xyaxis",
                            title: "Insights & Analytics",
                            subTitle: "View sales metrics, profit margins, and category performance to grow your business."
                        )
                    } footer: {
                        /// Footer
                        VStack(alignment: .leading, spacing: 6) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(Color.appTint)
                            
                            Text("Your data is stored securely on your device your own iCloud account and never shared with third parties.")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical, 15)
                    } onContinue: {
                        showOnBoarding = false
                        hasSeenOnboarding = true
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        print("✅ Onboarding completed - set hasSeenOnboarding to true")
                    }
                }
                
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
            .onChange(of: showSplash) { _, newValue in
                let shouldShowOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
                print("🔍 showSplash changed to: \(newValue), shouldShowOnboarding: \(shouldShowOnboarding)")
                
                if !newValue && shouldShowOnboarding {
                    // Show onboarding after splash screen disappears (only if not seen before)
                    print("🚀 Splash screen finished, showing onboarding...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        print("🚀 Setting showOnBoarding to true")
                        showOnBoarding = true
                    }
                }
            }
            .onAppear {
                print("🔍 hasSeenOnboarding: \(hasSeenOnboarding)")
                // For testing - uncomment next line to show onboarding immediately
                // showOnBoarding = true
            }
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


extension String {
    var localized: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}




struct ThemeSwitcher<Content: View>: View{
    @ViewBuilder var content: Content
    @AppStorage("AppTheme") private var appTheme: AppTheme = .systemDefault
    
    var body: some View {
        content
            .preferredColorScheme(appTheme.colorScheme)
    }
}


enum AppTheme: String, CaseIterable {

    case light = "Light"
    case dark = "Dark"
    case systemDefault = "System"
    
    var colorScheme: ColorScheme? {
        
        
        switch self {
        case .light: .light
        case .dark: .dark
        case .systemDefault: nil
         
        }
    }
}


