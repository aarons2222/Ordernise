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
    @State private var categoryToEdit: Category?
    @State private var isEditMode = false
    
    
    
    var body: some View {
        
        VStack{
            
            
            
            HeaderWithButton(
                title: "Categories",
                buttonContent: "plus.circle",
                isButtonImage: true,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    isEditMode = false
                    categoryToEdit = nil
                    resetCategoryForm()
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
                                .onTapGesture {
                                    categoryToEdit = category
                                    isEditMode = true
                                    newCategoryName = category.name
                                    newCategoryColor = category.colorHex
                                    showingAddCategory = true
                                }
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
            
            .GenericSheet(
                isPresented: $showingAddCategory,
                title: isEditMode ? "Edit Category" : "Add Category",
                showButton: false,
                action: {
                    print("Continue tapped")
                }
            ) {
                
                
                VStack(spacing: 30){
                    
                    
                    
                    
                    CustomTextField(text: $newCategoryName, placeholder: "Category Name", systemImage: "plus.square.on.square")
                        .padding(.top, 20)
                    
                    
                    CustomCardView{
                        
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                
                                
                                Text("Color")
                                    .font(.headline)
                                    .foregroundColor(.text)
                                
                                Text("Pick a color to quickly recognise items in this this category")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                
                            }
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
                    
                    
                    
                    Spacer()
                    
                    let isEmpty = newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty
      
                     
                    HStack{
                        
                        if isEditMode {
                            
                            
                            GlobalButton(title: "Delete", backgroundColor: Color.red) {
                                if let categoryToEdit = categoryToEdit {
                                    categoryToDelete = categoryToEdit
                                    showingAddCategory = false
                                }
                            }
                        
                    }
                        
                        
                        
                        GlobalButton(title: isEditMode ? "Update" : "Save", backgroundColor: isEmpty ? Color.gray.opacity(0.6) : Color.appTint) {
                            saveCategory()
                        }
                        .disabled(isEmpty)
                        
                        
                    }
                    

                    
                }
            }
                
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
        
    
    

    
    
    

    
    private func saveCategory() {
        if isEditMode, let categoryToEdit = categoryToEdit {
            // Update existing category
            categoryToEdit.name = newCategoryName.trimmingCharacters(in: .whitespaces)
            categoryToEdit.colorHex = newCategoryColor
        } else {
            // Create new category
            let category = Category(
                name: newCategoryName.trimmingCharacters(in: .whitespaces),
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



