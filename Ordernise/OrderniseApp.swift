//
//  OrderniseApp.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

@main
struct OrderniseApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StockItem.self,
            Order.self,
            OrderItem.self,
            Category.self,
            StockFieldPreferencesModel.self,
            OrderFieldPreferencesModel.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Initialize the FieldPreferencesManager with the model context
                    Task { @MainActor in
                        FieldPreferencesManager.shared.setModelContext(sharedModelContainer.mainContext)
                        
                        // Trigger migration from UserDefaults to SwiftData
                        FieldPreferencesManager.shared.migrateFromUserDefaults()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
