//
//  StockFieldSettings.swift
//  Ordernise
//
//  Created by Aaron Strickland on 10/08/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct StockFieldSettings: View {
    @State private var preferences: StockFieldPreferences
    @State private var showingAddFieldSheet = false
    @State private var editingField: CustomStockField? = nil

    @State var isEditMode: Bool = false
    @State var isEmpty: Bool = false
    @State var fieldName: String = ""

    init() {
        let prefs = UserDefaults.standard.stockFieldPreferences
        self._preferences = State(initialValue: prefs)
    }
    
    var body: some View {
        VStack {
            HeaderWithButton(
                title: "Stock Fields",
                buttonContent: "plus.circle",
                isButtonImage: true,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    showingAddFieldSheet = true
                }
            )
            
  
          
                    // Instructions
         
                            
                            
                            
                            let allFields = preferences.allFieldsInOrder
                            let _ = print("[DEBUG STOCK FOREACH] About to render \(allFields.count) fields")
                            let _ = allFields.enumerated().forEach { index, item in
                                if let builtIn = item.builtInField {
                                    print("[DEBUG STOCK FOREACH] Field[\(index)]: \(builtIn.rawValue) - ID: \(item.id)")
                                }
                            }
                            
                            
                        

                            List {
                                VStack{
                                    CustomCardView {
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack {
                                                Image(systemName: "info.circle")
                                                    .foregroundColor(.appTint)
                                                Text("Customize Your Stock Item Form")
                                                    .font(.headline)
                                                    .foregroundColor(.text)
                                                Spacer()
                                            }
                                            
                                            Text("• Drag to reorder fields\n• Toggle visibility on/off\n• Add custom fields with the + button\n• Required fields cannot be hidden")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                    }.padding(-15)
                                
                                    
                                  
                                  
                                            HStack {
                                                Text("Field Order & Visibility")
                                                    .font(.headline)
                                                    .foregroundColor(.text)
                                                
                                                Spacer()
                                                

                                            }.padding(.top)
                                    
                                    
                                    
                                    
                                }
                                ForEach(allFields, id: \.id) { fieldItem in
                                    DraggableStockFieldRow(
                                        fieldItem: fieldItem,
                                        preferences: $preferences,
                                        onTap: {
                                            if !fieldItem.isBuiltIn, let customField = fieldItem.customField {
                                                editingField = customField
                                                showingAddFieldSheet = true
                                            }
                                        }
                                    )
                                }
                                .onMove(perform: moveField)
                                .listRowSeparator(.hidden)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.thinMaterial)
                                )
                                
                                
                            }.scrollIndicators(.hidden)
                           
                            .listRowSpacing(10)
                            .scrollContentBackground(.hidden)
                    
            Color.clear.frame(height: 30)
                
                        
                
               
               
            
        }
        .navigationBarHidden(true)
        .onAppear {
            // Reload preferences from UserDefaults to ensure changes are reflected
            preferences = UserDefaults.standard.stockFieldPreferences
            
            print("[DEBUG STOCK] Raw fieldItems count: \(preferences.fieldItems.count)")
            for (index, item) in preferences.fieldItems.enumerated() {
                if let builtIn = item.builtInField {
                    print("[DEBUG STOCK] fieldItems[\(index)]: \(builtIn.rawValue) - sortOrder: \(item.sortOrder) - visible: \(item.isVisible)")
                } else if let custom = item.customField {
                    print("[DEBUG STOCK] fieldItems[\(index)]: custom_\(custom.name) - sortOrder: \(item.sortOrder) - visible: \(item.isVisible)")
                }
            }
            
            print("[DEBUG STOCK] allFieldsInOrder count: \(preferences.allFieldsInOrder.count)")
            for (index, item) in preferences.allFieldsInOrder.enumerated() {
                if let builtIn = item.builtInField {
                    print("[DEBUG STOCK] allFieldsInOrder[\(index)]: \(builtIn.rawValue) - isVisible: \(item.isVisible)")
                } else if let custom = item.customField {
                    print("[DEBUG STOCK] allFieldsInOrder[\(index)]: custom_\(custom.name) - isVisible: \(item.isVisible)")
                }
            }
        }
        .GenericSheet(
            isPresented: $showingAddFieldSheet,
            title: editingField != nil ? "Edit Custom Field" : "Add Custom Field",
            showButton: false,
            action: {
                // Action when sheet is dismissed
                editingField = nil
            }
        ) {
            AddCustomStockFieldContent(
                editingField: editingField,
                onSave: { newField in
                    if editingField != nil {
                        // Update existing field
                        if let index = preferences.fieldItems.firstIndex(where: {
                            !$0.isBuiltIn && $0.customField?.id == editingField?.id
                        }) {
                            preferences.fieldItems[index] = StockFieldItem(
                                customField: newField,
                                isVisible: preferences.fieldItems[index].isVisible,
                                sortOrder: preferences.fieldItems[index].sortOrder
                            )
                        }
                    } else {
                        // Add new field
                        preferences.addCustomField(newField)
                    }
                    savePreferences()
                    showingAddFieldSheet = false
                    editingField = nil
                },
                onDelete: {
                    if let editingField = editingField {
                        // Remove the custom field
                        preferences.removeField(withId: "custom_\(editingField.name)")
                        savePreferences()
                        showingAddFieldSheet = false
                        self.editingField = nil
                    }
                }
            )
        }
    }
    
    private func applyPreset(_ preset: StockFieldPreferences) {
        preferences = preset
        savePreferences()
    }
    
    private func moveField(from source: IndexSet, to destination: Int) {
        preferences.fieldItems.move(fromOffsets: source, toOffset: destination)
        preferences.updateSortOrders()
        savePreferences()
    }
    
    private func savePreferences() {
        UserDefaults.standard.stockFieldPreferences = preferences
    }
}

//struct DraggableStockFieldRow: View {
//    let fieldItem: StockFieldItem
//    @Binding var preferences: StockFieldPreferences
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            // Drag handle
//            Image(systemName: "line.3.horizontal")
//                .foregroundColor(.secondary)
//                .font(.caption)
//            
//            // Field icon
//            Image(systemName: fieldItem.systemImage)
//                .foregroundColor(.appTint)
//                .frame(width: 20)
//            
//            // Field name
//            VStack(alignment: .leading, spacing: 2) {
//                Text(fieldItem.displayName)
//                    .font(.body)
//                    .foregroundColor(.primary)
//                
//                if fieldItem.isRequired {
//                    Text("Required")
//                        .font(.caption2)
//                        .foregroundColor(.orange)
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 2)
//                        .background(Color.orange.opacity(0.1))
//                        .cornerRadius(4)
//                }
//            }
//            
//            Spacer()
//            
//            // Custom field actions
//            if !fieldItem.isBuiltIn {
//                Button {
//                    preferences.removeField(withId: fieldItem.id)
//                    UserDefaults.standard.stockFieldPreferences = preferences
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//                .buttonStyle(.plain)
//            }
//            
//            // Visibility toggle
//            Toggle("", isOn: Binding(
//                get: { fieldItem.isVisible },
//                set: { newValue in
//                    if let index = preferences.fieldItems.firstIndex(where: { $0.id == fieldItem.id }) {
//                        preferences.fieldItems[index].isVisible = newValue
//                        UserDefaults.standard.stockFieldPreferences = preferences
//                    }
//                }
//            ))
//            .disabled(fieldItem.isRequired)
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//

struct DraggableStockFieldRow: View {
    let fieldItem: StockFieldItem
    @Binding var preferences: StockFieldPreferences
    let onTap: () -> Void

    var body: some View {
        HStack {
            
            
            // Field icon
            Image(systemName: fieldItem.systemImage)
                .foregroundColor(.appTint)
                .font(.body)
                
            
            // Field info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(fieldItem.displayName)
                        .font(.body)
                        .foregroundColor(.text)
                    
                 
                }
                
                if !fieldItem.isBuiltIn {
                    Text(fieldItem.customField?.fieldType.displayName ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            
      
            
            if fieldItem.isRequired {
                Text("Required")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }else{
                Toggle("", isOn: Binding(
                    get: { fieldItem.isVisible },
                    set: { newValue in
                        if let index = preferences.fieldItems.firstIndex(where: { $0.id == fieldItem.id }) {
                            preferences.fieldItems[index].isVisible = newValue
                            UserDefaults.standard.stockFieldPreferences = preferences
                        }
                    }
                ))
                .tint(Color.appTint)
                .disabled(fieldItem.isRequired)
                
            }
        }
        .frame(height: 40)
        .contentShape(Rectangle())
        .onTapGesture {
            if !fieldItem.isBuiltIn {
                onTap()
            }
        }
        .scaleEffect(1.0)
        .opacity(1.0)
        .brightness(0.0)
        .animation(.none, value: UUID())
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}

















struct AddCustomStockFieldContent: View {
    let editingField: CustomStockField?
    let onSave: (CustomStockField) -> Void
    let onDelete: () -> Void
    
    @State private var fieldName = ""
    @State private var isEmpty: Bool = true
    
    private var isEditMode: Bool {
        editingField != nil
    }
    
    private func addField() {
        let newField = CustomStockField(
            name: fieldName,
            placeholder: "Enter \(fieldName.lowercased())",
            fieldType: .text,
            isRequired: false
        )
        onSave(newField)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Field Name")
                    .font(.headline)
                    .foregroundColor(.text)
                
                CustomTextField(
                    text: $fieldName,
                    placeholder: "Enter custom field name",
                    systemImage: "textformat"
                )
                .onChange(of: fieldName) { _, newValue in
                    isEmpty = newValue.trimmingCharacters(in: .whitespaces).isEmpty
                }
                .onAppear {
                    if let editingField = editingField {
                        fieldName = editingField.name
                        isEmpty = fieldName.trimmingCharacters(in: .whitespaces).isEmpty
                    }
                }
                
                Text("This will create a text field in your stock item form")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Spacer()
            
            HStack {
                if isEditMode {
                    GlobalButton(title: "Delete", backgroundColor: Color.red) {
                        onDelete()
                    }
                }
                
                GlobalButton(title: isEditMode ? "Update" : "Save", backgroundColor: isEmpty ?  Color.gray.opacity(0.6) : Color.appTint) {
                    addField()
                }
                .disabled(isEmpty)
            }
        }
    }
}

#Preview {
    StockFieldSettings()
}
