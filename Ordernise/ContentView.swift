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





