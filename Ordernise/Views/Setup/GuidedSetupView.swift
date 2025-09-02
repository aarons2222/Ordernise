//
//  GuidedSetupView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 01/09/2025.
//

import SwiftUI
import SwiftData

struct GuidedSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var hasCompletedInitialSetup: Bool
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \StockItem.name) private var stockItems: [StockItem]
    
    @State private var showingAddCategory = false
    @State private var showingAddStock = false
    @State private var isCompleting = false
    
    // Computed properties for completion status
    private var hasCategories: Bool {
        !categories.isEmpty
    }
    
    private var hasStockItems: Bool {
        !stockItems.isEmpty
    }
    
    private var canComplete: Bool {
        hasCategories && hasStockItems
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "checklist")
                        .font(.system(size: 48))
                        .foregroundColor(.appTint)
                        .padding(.top, 10)
                    
                    VStack(spacing: 8) {
                        Text("Let's set up Ordernise")
                            .font(.title.bold())
                        
                        Text("Complete these steps to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 40)
                
          
                
                // Checklist
                VStack(spacing: 20) {
                    // Category Step
                    ChecklistItem(
                        title: "Add a Category",
                        subtitle: "Create your first product category",
                        isCompleted: hasCategories,
                        completedCount: categories.count,
                        icon: "folder.badge.plus",
                        buttonTitle: hasCategories ? "Add Another" : "Add Category"
                    ) {
                        showingAddCategory = true
                    }
                    
                    // Stock Item Step
                    ChecklistItem(
                        title: "Add a Stock Item",
                        subtitle: "Create your first inventory item",
                        isCompleted: hasStockItems,
                        completedCount: stockItems.count,
                        icon: "cube.box",
                        buttonTitle: hasStockItems ? "Add Another" : "Add Stock Item",
                        isDisabled: !hasCategories
                    ) {
                        if hasCategories {
                            showingAddStock = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Complete Setup Button
                VStack(spacing: 16) {
                    if !canComplete {
                        VStack(spacing: 8) {
                            Text("Complete the steps above to continue")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Button(action: completeSetup) {
                        HStack {
                            if isCompleting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } 
                            
                            Text(isCompleting ? "Completing Setup..." : "Complete Setup")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                           Capsule()
                                .fill(canComplete ? Color.appTint : Color.gray.opacity(0.4))
                        )
                    }
                    .disabled(!canComplete || isCompleting)
                    .padding(.horizontal, 24)
                }
              
            }
       
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryCreationView()
        }
        .sheet(isPresented: $showingAddStock) {
            StockItemDetailView(mode: .add)
        }
    }
    
    private func completeSetup() {
        isCompleting = true
        
        // Brief delay for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasCompletedInitialSetup = true
            UserDefaults.standard.set(true, forKey: "hasCompletedInitialSetup")
            isCompleting = false
            // Don't dismiss here - let InitialSetupView handle the dismissal
        }
    }
}

struct ChecklistItem: View {
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let completedCount: Int
    let icon: String
    let buttonTitle: String
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion indicator
      
            VStack(alignment: .leading, spacing: 4) {
           
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                 
                    
               
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            ZStack {
              
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(Color.appTint)
                } else {
                    Button(action: action) {
                        
                        Image(systemName: "chevron.forward.circle")
                            .font(.title)
                            .foregroundColor(Color.appTint)
                        
                    }
                }
            }
            
            
//            Button(action: action) {
//                HStack(spacing: 6) {
//                    Image(systemName: icon)
//                        .font(.caption)
//                    Text(buttonTitle)
//                        .font(.caption.bold())
//                }
//                .foregroundColor(isDisabled ? .gray : .appTint)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 6)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(isDisabled ? Color.gray.opacity(0.3) : Color.appTint.opacity(0.3), lineWidth: 1)
//                        .fill(isDisabled ? Color.gray.opacity(0.1) : Color.appTint.opacity(0.1))
//                )
//            }
            .disabled(isDisabled)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .stroke(isCompleted ? Color.appTint.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// Simple category creation view extracted from StockItemDetailView
struct CategoryCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var categoryName = ""
    @State private var categoryColor = "#007AFF"
    
    private var isValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.appTint)
                    
                    VStack(spacing: 8) {
                        Text("Create Category")
                            .font(.title2.bold())
                        Text("Organize your inventory with categories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
  
                
                VStack(spacing: 20) {
                    CustomTextField(
                        text: $categoryName,
                        placeholder: "Category Name",
                        systemImage: "tag"
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Color")
                                    .font(.headline)
                                Text("Choose a color to identify this category")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            ColorPicker("", selection: Binding(
                                get: { Color(hex: categoryColor) ?? Color.appTint },
                                set: { color in
                                    categoryColor = color.toHex()
                                }
                            ))
                            .labelsHidden()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                
                Spacer()
                
                Button(action: saveCategory) {
                    Text("Create Category")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Capsule()
                                .fill(isValid ? Color.appTint : Color.gray.opacity(0.4))
                        )
                }
                .disabled(!isValid)
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    }label: {
                        Image(systemName: "multiply.circle")
                            .font(.title2)
                            .foregroundStyle(Color.appTint)
                    }
                }
            }
        }
    }
    
    private func saveCategory() {
        let category = Category(
            name: categoryName.trimmingCharacters(in: .whitespaces),
            colorHex: categoryColor
        )
        
        modelContext.insert(category)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save category: \(error)")
        }
    }
}

#Preview {
    GuidedSetupView(hasCompletedInitialSetup: .constant(false))
        .modelContainer(for: [Category.self, StockItem.self, Order.self])
}
