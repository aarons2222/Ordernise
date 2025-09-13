//
//  FieldPreferencesModels.swift
//  Ordernise
//
//  Created by Aaron Strickland on 10/08/2025.
//

import Foundation
import SwiftData

// MARK: - SwiftData Models for Field Preferences

@Model
class StockFieldPreferencesModel {
    var id: String = "default"
    var fieldItemsData: Data = Data()
    var version: Int = 1
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(id: String = "default", fieldItemsData: Data, version: Int = 1) {
        self.id = id
        self.fieldItemsData = fieldItemsData
        self.version = version
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateData(_ data: Data) {
        self.fieldItemsData = data
        self.updatedAt = Date()
    }
}

@Model
class OrderFieldPreferencesModel {
    var id: String = "default"
    var fieldItemsData: Data = Data()
    var version: Int = 1
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(id: String = "default", fieldItemsData: Data, version: Int = 1) {
        self.id = id
        self.fieldItemsData = fieldItemsData
        self.version = version
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateData(_ data: Data) {
        self.fieldItemsData = data
        self.updatedAt = Date()
    }
}

// MARK: - Field Preferences Manager
@MainActor
class FieldPreferencesManager {
    static let shared = FieldPreferencesManager()
    private var _modelContext: ModelContext?
    
    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self._modelContext = context
    }
    
    var modelContext: ModelContext? {
        return _modelContext
    }
    
    // MARK: - Stock Field Preferences
    func loadStockFieldPreferences() -> StockFieldPreferences? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<StockFieldPreferencesModel>(
            predicate: #Predicate { $0.id == "default" }
        )
        
        do {
            let models = try context.fetch(descriptor)
            guard let model = models.first else { return nil }
            
            return try JSONDecoder().decode(StockFieldPreferences.self, from: model.fieldItemsData)
        } catch {
            print("[FieldPreferencesManager] Error loading stock preferences: \(error)")
            return nil
        }
    }
    
    func saveStockFieldPreferences(_ preferences: StockFieldPreferences) {
        guard let context = modelContext else { return }
        
        do {
            let data = try JSONEncoder().encode(preferences)
            
            let descriptor = FetchDescriptor<StockFieldPreferencesModel>(
                predicate: #Predicate { $0.id == "default" }
            )
            
            let existingModels = try context.fetch(descriptor)
            
            if let existingModel = existingModels.first {
                existingModel.updateData(data)
            } else {
                let newModel = StockFieldPreferencesModel(fieldItemsData: data)
                context.insert(newModel)
            }
            
            try context.save()
        } catch {
            print("[FieldPreferencesManager] Error saving stock preferences: \(error)")
        }
    }
    
    // MARK: - Order Field Preferences
    func loadOrderFieldPreferences() -> OrderFieldPreferences? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<OrderFieldPreferencesModel>(
            predicate: #Predicate { $0.id == "default" }
        )
        
        do {
            let models = try context.fetch(descriptor)
            guard let model = models.first else { return nil }
            
            return try JSONDecoder().decode(OrderFieldPreferences.self, from: model.fieldItemsData)
        } catch {
            print("[FieldPreferencesManager] Error loading order preferences: \(error)")
            return nil
        }
    }
    
    func saveOrderFieldPreferences(_ preferences: OrderFieldPreferences) {
        guard let context = modelContext else { return }
        
        do {
            let data = try JSONEncoder().encode(preferences)
            
            let descriptor = FetchDescriptor<OrderFieldPreferencesModel>(
                predicate: #Predicate { $0.id == "default" }
            )
            
            let existingModels = try context.fetch(descriptor)
            
            if let existingModel = existingModels.first {
                existingModel.updateData(data)
            } else {
                let newModel = OrderFieldPreferencesModel(fieldItemsData: data)
                context.insert(newModel)
            }
            
            try context.save()
        } catch {
            print("[FieldPreferencesManager] Error saving order preferences: \(error)")
        }
    }
    
    // MARK: - Migration Helper
    func migrateFromUserDefaults() {
        // Migrate stock preferences
        if loadStockFieldPreferences() == nil {
            if let data = UserDefaults.standard.data(forKey: "stockFieldPreferences"),
               let preferences = try? JSONDecoder().decode(StockFieldPreferences.self, from: data) {
                print("[FieldPreferencesManager] Migrating stock preferences from UserDefaults to SwiftData")
                saveStockFieldPreferences(preferences)
            }
        }
        
        // Migrate order preferences
        if loadOrderFieldPreferences() == nil {
            if let data = UserDefaults.standard.data(forKey: "orderFieldPreferences"),
               let preferences = try? JSONDecoder().decode(OrderFieldPreferences.self, from: data) {
                print("[FieldPreferencesManager] Migrating order preferences from UserDefaults to SwiftData")
                saveOrderFieldPreferences(preferences)
            }
        }
    }
}
