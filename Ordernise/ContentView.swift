//
//  ContentView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI

enum AppTab: String, CaseIterable, FloatingTabProtocol {
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

    private let selectedTabKey = "selectedTab"

    init() {
        // Load the saved tab from UserDefaults
        if let savedTab = UserDefaults.standard.string(forKey: selectedTabKey),
           let tab = AppTab(rawValue: savedTab) {
            _activeTab = State(initialValue: tab)
        }
    }

    var body: some View {
        FloatingTabView(selection: $activeTab) { tab, tabBarHeight in
            switch tab {
            case .dashboard:
                DashboardView()
            case .orders:
                OrderList()
            case .stock:
                StockList()
            case .settings:
                SettingsView()
            }
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
