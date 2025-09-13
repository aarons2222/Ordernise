//
//  CategoryFormView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 03/09/2025.
//

import SwiftUI

struct CategoryFormView: View {
    let categoryToEdit: Category?
    @Binding var categoryName: String
    @Binding var categoryColor: String
    @Binding var categoryIcon: String
    let retailSymbols: [String]
    let onSave: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    private var isEditMode: Bool {
        categoryToEdit != nil
    }
    
    private var isEmpty: Bool {
        categoryName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            
            VStack{
                HStack{
                Text(isEditMode ? String(localized: "Edit Category") : String(localized: "Add Category"))
                    .font(.title)
                    .lineLimit(2)
                    .minimumScaleFactor(0.2)
                    .truncationMode(.tail)
                    .padding(.horizontal, 15)
                
                Spacer()
                
                
                Button {
                    onCancel()
                } label: {
                    
                    Image(systemName: "multiply.circle")
                        .font(.title)
                        .foregroundColor(.appTint)
                    
                }
                .padding(.horizontal)
                .padding(.top)
            }
                 
            ScrollView(showsIndicators: false){
                
                VStack(spacing: 0) {
                    
                    
                    Spacer(minLength: 20)
                    
                    GeometryReader { proxy in
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Spacer()
                                Image(systemName: categoryIcon)
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                
                                Spacer()
                                Text(categoryName.isEmpty ? "Category" : categoryName)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(2)
                            }
                            .padding(18)
                            .frame(width: proxy.size.width * 0.5, height: 120)
                            .background(Color(hex: categoryColor)?.gradient ?? Color.appTint.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            Spacer()
                        }
                    }
                    .frame(height: 120)
                    
                    Spacer(minLength: 20)
                    
                    
                    CustomTextField(text: $categoryName, placeholder: String(localized: "Category Name"), systemImage: "textformat.alt")
                        .padding(.top, 20)
                    Spacer(minLength: 20)
                    
                    // Symbol Picker
                    CustomCardView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(localized: "Icon"))
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    Text(String(localized: "Choose an icon for \(categoryName)"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: categoryIcon)
                                    .font(.title2)
                                    .contentTransition(.opacity)
                                    .foregroundColor(.appTint)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: Array(repeating: GridItem(.fixed(40), spacing: 8), count: 3), spacing: 12) {
                                    ForEach(retailSymbols, id: \.self) { symbol in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                categoryIcon = symbol
                                            }
                                        } label: {
                                            let isSelected = (categoryIcon == symbol)
                                            
                                            Image(systemName: symbol)
                                                .font(.title)
                                                .foregroundColor(isSelected ? Color.appTint : .primary)
                                                .opacity(isSelected ? 1 : 0.55) // fade in/out on select
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.appTint, lineWidth: 2)
                                                        .opacity(isSelected ? 1 : 0) // border fades in/out
                                                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        .buttonStyle(.plain)
                                        .animation(.easeInOut(duration: 0.2), value: categoryIcon)
                                        
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            
                        }
                    }
                    Spacer(minLength: 20)
                    
                    // Color Picker
                    CustomCardView {
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
                                get: { Color(hex: categoryColor) ?? Color.appTint },
                                set: { color in
                                    categoryColor = color.toHex()
                                }
                            ))
                            .labelsHidden()
                        }
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack {
                        
                        GlobalButton(title: isEditMode ? String(localized: "Update") : String(localized: "Save"), backgroundColor: isEmpty ? Color.gray.opacity(0.6) : Color.appTint) {
                            DispatchQueue.main.async {
                                
                                ToastManager.shared.showToast(
                                    type: .success,
                                    title: String(localized: "Success"),
                                    message: isEditMode ? String(localized: "Category updated successfully") : String(localized: "Category created successfully")
                                )
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                onSave()
                            }
                        }
                        .disabled(isEmpty)
                        
                        
                        if isEditMode {
                            GlobalButton(title: String(localized: "Delete"), backgroundColor: Color.red) {
                                onDelete()
                            }
                        }
                        
                       
                    }
                }
                .padding(.horizontal, 5)
            }
            .padding(.horizontal, 15)
            
        }
        .toastView()
       

        }
    }
}

#Preview {
    CategoryFormView(
        categoryToEdit: nil,
        categoryName: .constant(""),
        categoryColor: .constant("#007AFF"),
        categoryIcon: .constant("folder.fill"),
        retailSymbols: ["bag.fill", "cart.fill", "tag.fill"],
        onSave: {},
        onDelete: {},
        onCancel: {}
    )
}
