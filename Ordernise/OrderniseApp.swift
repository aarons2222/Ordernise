//
//  OrderniseApp.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData
// Add to OrderniseApp.swift
import os.log


@main
struct OrderniseApp: App {
    
    @Environment(\.scenePhase) private var scenePhase

    
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
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.ordernisesales")
        )
        
        os_log("CloudKit container: iCloud.ordernisesales", log: .default, type: .info)

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
            
                .environment(\.stockManager, StockManager(modelContext: sharedModelContainer.mainContext))
                .task {
                    // Initialize the FieldPreferencesManager with the model context
                    FieldPreferencesManager.shared.setModelContext(sharedModelContainer.mainContext)
                    
                    // Run migration asynchronously to avoid SwiftUI publishing warnings
                    Task.detached { @MainActor in
                        // Small delay to ensure view setup is complete
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                        FieldPreferencesManager.shared.migrateFromUserDefaults()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) {
                   if scenePhase == .active {
                       // Clear badge every time app becomes active
                       UNUserNotificationCenter.current().setBadgeCount(0) { error in
                           if let error = error {
                               print("Failed to clear badge: \(error)")
                           }
                       }
                   }
               }
    }
}
