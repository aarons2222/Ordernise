//
//  CategoryOptions.swift
//  Ordernise
//
//  Created by Aaron Strickland on 29/07/2025.
//

import SwiftUI
import SwiftData


struct CategoryOptions: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dummyDataManager = DummyDataManager.shared
    
    // Retail-related SF Symbols
 
    
    private var categories: [Category] {
        dummyDataManager.getCategories(from: modelContext)
    }
    
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryColor = "#007AFF"
    @State private var newCategoryIcon = "folder.fill"
    @State private var categoryToDelete: Category?
    @State private var categoryToEdit: Category?
    @State private var isEditMode = false
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State var showPaywall: Bool = false
     
    
    var body: some View {
        
        VStack{
            
            
            
            HeaderWithButton(
                title: String(localized: "Categories"),
                buttonContent: "plus.circle",
                isButtonImage: true,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    
                    if categories.count >= 2 && !subscriptionManager.isSubscribed {
                        showPaywall = true
                    } else {
                        isEditMode = false
                        categoryToEdit = nil
                        resetCategoryForm()
                        showingAddCategory = true
                    }

                  
                }
            )
           
         
                    if categories.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            String(localized: "No Categories"),
                            systemImage: "folder",
                            description: Text(String(localized: "Tap ")) + 
                                        Text(Image(systemName: "plus.circle")) + 
                                        Text(String(localized: " to add your first category."))
                        )
                        
                        
                        Spacer()
                        
                        
                    } else {
                        
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                ForEach(categories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { category in
                                    CategoryGridItem(category: category)
                                        .onTapGesture {
                                            isEditMode = true
                                            newCategoryName = category.name
                                            newCategoryColor = category.colorHex
                                            newCategoryIcon = category.icon
                                            categoryToEdit = category
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                categoryToDelete = category
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                
    }
        
        
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    
        
        .toolbar(.hidden)
        
        
      
            
        
            .alert(String(localized: "Delete Category"), isPresented: Binding<Bool>(
                get: { categoryToDelete != nil },
                set: { _ in categoryToDelete = nil }
            )) {
                Button(String(localized: "Delete"), role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategory(category)
                    }
                    categoryToDelete = nil
                }
                Button(String(localized: "Cancel"), role: .cancel) {
                    categoryToDelete = nil
                }
            } message: {
                Text(String(localized: "Are you sure you want to delete this category? This action cannot be undone."))
            }
        
        .fullScreenCover(item: $categoryToEdit) { category in
            CategoryFormView(
                categoryToEdit: category,
                categoryName: $newCategoryName,
                categoryColor: $newCategoryColor,
                categoryIcon: $newCategoryIcon,
                retailSymbols: retailSymbols,
                onSave: saveCategory,
                onDelete: {
                    categoryToDelete = category
                    categoryToEdit = nil
                },
                onCancel: {
                    categoryToEdit = nil
                    resetCategoryForm()
                    isEditMode = false
                }
            )
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { showingAddCategory && categoryToEdit == nil },
            set: { _ in showingAddCategory = false }
        )) {
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
                    isEditMode = false
                }
            )
        }
        
        }
        
    
    

    
    
    

    
    private func saveCategory() {
        if isEditMode, let categoryToEdit = categoryToEdit {
            // Update existing category
            categoryToEdit.name = newCategoryName.trimmingCharacters(in: .whitespaces)
            categoryToEdit.colorHex = newCategoryColor
            categoryToEdit.icon = newCategoryIcon
        } else {
            // Create new category
            let category = Category(
                name: newCategoryName.trimmingCharacters(in: .whitespaces),
                icon: newCategoryIcon,
                colorHex: newCategoryColor
         
            )
            modelContext.insert(category)
        }
        
        do {
            try modelContext.save()
            showingAddCategory = false
            resetCategoryForm()
            categoryToEdit = nil
            isEditMode = false
        } catch {
            print("Failed to save category: \(error)")
        }
    }
    
    private func resetCategoryForm() {
        newCategoryName = ""
        newCategoryColor = "#007AFF"
        newCategoryIcon = "folder.fill"
    }
    
    private func deleteCategory(_ category: Category) {
        withAnimation {
            modelContext.delete(category)
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete category: \(error)")
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(categories[index])
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete categories: \(error)")
            }
        }
    }
    
}
    


struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            Image(systemName: "largecircle.fill.circle")
                .font(.body)
                .foregroundStyle(category.color)
            
            Text(category.name)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
       
        .cardBackground()
        .padding(.horizontal)
    }
}

struct CategoryGridItem: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            Image(systemName: category.icon)
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
            Spacer()
            
            Text(category.name)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
             
    
        }
        .padding(18)
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(category.color.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CategoryOptions()
}



