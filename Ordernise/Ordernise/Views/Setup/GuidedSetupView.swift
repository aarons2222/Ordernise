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
    
    // Category form state
    @State private var newCategoryName = ""
    @State private var newCategoryColor = "#007AFF"
    @State private var newCategoryIcon = "folder.fill"
    
    // Retail-related SF Symbols
    private let retailSymbols = [
        "bag", "bag.circle", "bag.fill", "handbag", "cart", "cart.circle", "cart.fill",
        "basket", "tray", "tray.circle", "tray.fill", "archivebox", "archivebox.circle",
        "shippingbox", "box.truck", "truck.box", "creditcard", "banknote", "dollarsign.circle",
        "eurosign.circle", "sterlingsign.circle", "yensign.circle", "bitcoinsign.circle",
        "tag", "tag.circle", "bookmark", "bookmark.circle", "heart", "heart.circle",
        "star", "star.circle", "gift", "gift.circle", "crown", "diamond",
        "circle", "square", "triangle", "hexagon", "seal", "rosette",
        "tshirt", "shoe", "watch.analog", "eyeglasses", "sunglasses", "car",
        "bicycle", "scooter", "gamecontroller", "headphones.circle", "camera", "desktopcomputer",
        "laptopcomputer", "iphone", "ipad", "applewatch", "airpods", "tv",
        "book", "magazine", "newspaper", "graduationcap", "paintbrush", "pencil.circle",
        "hammer", "wrench", "screwdriver", "keyboard", "printer", "scanner",
        "house", "building.2", "storefront", "tent", "bed.double", "sofa",
        "chair", "lamp.table", "lamp.floor", "lightbulb", "fan", "refrigerator",
        "oven", "washer", "cup.and.saucer", "wineglass", "mug", "takeoutbag.and.cup.and.straw",
        "fork.knife.circle", "leaf", "flower", "tree", "carrot", "apple.logo",
        "figure.walk", "figure.run", "dumbbell", "tennis.racket", "basketball", "football",
        "soccerball", "baseball", "hockey.puck", "dice", "puzzlepiece",
        "music.note", "guitars", "pianokeys", "mic", "speaker", "hifispeaker"
    ]
    
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
        .fullScreenCover(isPresented: $showingAddCategory) {
            CategoryFormView(
                categoryToEdit: nil,
                categoryName: $newCategoryName,
                categoryColor: $newCategoryColor,
                categoryIcon: $newCategoryIcon,
                retailSymbols: retailSymbols,
                onSave: saveCategory,
                onDelete: {},
                onCancel: {
                    showingAddCategory = false
                    resetCategoryForm()
                }
            )
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
    
    private func saveCategory() {
        let category = Category(
            name: newCategoryName.trimmingCharacters(in: .whitespaces),
            icon: newCategoryIcon,
            colorHex: newCategoryColor
       
        )
        modelContext.insert(category)
        
        do {
            try modelContext.save()
            showingAddCategory = false
            resetCategoryForm()
        } catch {
            print("Failed to save category: \(error)")
        }
    }
    
    private func resetCategoryForm() {
        newCategoryName = ""
        newCategoryColor = "#007AFF"
        newCategoryIcon = "folder.fill"
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


#Preview {
    GuidedSetupView(hasCompletedInitialSetup: .constant(false))
        .modelContainer(for: [Category.self, StockItem.self, Order.self])
}
