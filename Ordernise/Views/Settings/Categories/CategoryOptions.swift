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
    
    private var categories: [Category] {
        dummyDataManager.getCategories(from: modelContext)
    }
    
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryColor = "#007AFF"
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
                            LazyVStack(spacing: 12) {
                                
                                
                                ForEach(categories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { category in
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
                        
                    }
                
    }
        
        
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    
        
        .navigationBarHidden(true)
        
        
      
            
        
            .alert(String(localized: "Delete Category"), isPresented: .constant(categoryToDelete != nil)) {
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
        
      .GenericSheet(
          isPresented: $showingAddCategory,
          title: isEditMode ? String(localized: "Edit Category") : String(localized: "Add Category"),
          showButton: false,
          action: {
              print("Continue tapped")
          }
      ) {
          
          
          VStack(spacing: 30){
              
              
              
                            CustomTextField(text: $newCategoryName, placeholder: String(localized: "Category Name"), systemImage: "plus.square.on.square")
                  .padding(.top, 20)
              
              
              CustomCardView{
                  
                  
                  HStack {
                      VStack(alignment: .leading, spacing: 8) {
                          
                                                    Text(String(localized: "Color"))
                               .font(.headline)
                               .foregroundColor(.text)
                           
                           Text(String(localized: "Pick a color to quickly recognise items in this this category"))
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
                      
                                            GlobalButton(title: String(localized: "Delete"), backgroundColor: Color.red) {
                          if let categoryToEdit = categoryToEdit {
                              categoryToDelete = categoryToEdit
                              showingAddCategory = false
                          }
                      }
                  
              }
                  
                  
                                    GlobalButton(title: isEditMode ? String(localized: "Update") : String(localized: "Save"), backgroundColor: isEmpty ? Color.gray.opacity(0.6) : Color.appTint) {
                      saveCategory()
                  }
                  .disabled(isEmpty)
                  
                  
              }
              

              
          }
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



