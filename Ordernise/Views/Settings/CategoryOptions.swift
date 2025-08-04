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

    @Query(sort: \Category.name) private var categories: [Category]

    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryColor = "#007AFF"
    @State private var categoryToDelete: Category?
    
    
    
    
    var body: some View {
        
        VStack{
            
       
            
            HeaderWithButton(
                title: "Categories",
                buttonContent: "plus.circle",
                isButtonImage: true,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    showingAddCategory = true
                    
                }
            )
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    if categories.isEmpty {
                        ContentUnavailableView(
                            "No Categories",
                            systemImage: "folder",
                            description: Text("Tap + to add your first category.")
                        )
                        .padding(.top, 50)
                    } else {
                        ForEach(categories) { category in
                            CategoryRow(category: category)
                                .swipeActions {
                                    Action(symbolImage: "trash.fill", tint: .white, background: .red) { resetPosition in
                                        categoryToDelete = category
                                        resetPosition = true
                                    }
                                }
                        }
                        
                        
                    }
                }
                
                .navigationBarHidden(true)
                
                
            }
         
            .sheet(isPresented: $showingAddCategory) {
                addCategorySheet
            }
            .alert("Delete Category", isPresented: .constant(categoryToDelete != nil)) {
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategory(category)
                    }
                    categoryToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    categoryToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this category? This action cannot be undone.")
            }
        }
   
    }
    
    
    private var addCategorySheet: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Category Name", text: $newCategoryName)
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: newCategoryColor) ?? Color.appTint },
                            set: { color in
                                newCategoryColor = color.toHex()
                            }
                        ))
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddCategory = false
                        resetCategoryForm()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let category = Category(
            name: newCategoryName.trimmingCharacters(in: .whitespaces),
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

#Preview {
    CategoryOptions()
}



