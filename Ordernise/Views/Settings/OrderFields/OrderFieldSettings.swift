//
//  OrderFieldSettings.swift
//  Ordernise
//
//  Created by Aaron Strickland on 07/08/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct OrderFieldSettings: View {
    @State private var preferences: OrderFieldPreferences
    @State private var showingAddFieldSheet = false
    @State private var editingField: CustomOrderField? = nil

    @State var isEditMode: Bool = false
    @State var isEmpty: Bool = false
    @State var fieldName: String = ""

    
    
    init() {
        let prefs = UserDefaults.standard.orderFieldPreferences
        self._preferences = State(initialValue: prefs)
    }
    
    var body: some View {
        VStack {
            HeaderWithButton(
                title: "Order Fields",
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
                            let _ = print("[DEBUG FOREACH] About to render \(allFields.count) fields")
                            let _ = allFields.enumerated().forEach { index, item in
                                if let builtIn = item.builtInField {
                                    print("[DEBUG FOREACH] Field[\(index)]: \(builtIn.rawValue) - ID: \(item.id)")
                                }
                            }
                            
                            
                        

                            List {
                                VStack{
                                    CustomCardView {
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack {
                                                Image(systemName: "info.circle")
                                                    .foregroundColor(.appTint)
                                                Text("Customize Your Order Form")
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
                                    DraggableFieldRow(
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
            preferences = UserDefaults.standard.orderFieldPreferences
            
            print("[DEBUG] Raw fieldItems count: \(preferences.fieldItems.count)")
            for (index, item) in preferences.fieldItems.enumerated() {
                if let builtIn = item.builtInField {
                    print("[DEBUG] fieldItems[\(index)]: \(builtIn.rawValue) - sortOrder: \(item.sortOrder) - visible: \(item.isVisible)")
                } else {
                    print("[DEBUG] fieldItems[\(index)]: custom field - sortOrder: \(item.sortOrder) - visible: \(item.isVisible)")
                }
            }
            
            print("[DEBUG] allFieldsInOrder count: \(preferences.allFieldsInOrder.count)")
            for (index, item) in preferences.allFieldsInOrder.enumerated() {
                if let builtIn = item.builtInField {
                    print("[DEBUG] allFieldsInOrder[\(index)]: \(builtIn.rawValue) - sortOrder: \(item.sortOrder)")
                }
            }
        }
        .onChange(of: preferences) { _, newValue in
            UserDefaults.standard.orderFieldPreferences = newValue
           
        }
      
        .GenericSheet(
            isPresented: $showingAddFieldSheet,
            title: editingField != nil ? "Edit Custom Field" : "Add Custom Field",
            showButton: false,
            action: {
                editingField = nil
            }
        ) {
            AddCustomOrderFieldContent(
                editingField: editingField,
                onSave: { newField in
                    if editingField != nil {
                        // Update existing field
                        if let index = preferences.fieldItems.firstIndex(where: {
                            !$0.isBuiltIn && $0.customField?.id == editingField?.id
                        }) {
                            preferences.fieldItems[index] = OrderFieldItem(
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
    
    private func savePreferences() {
        UserDefaults.standard.orderFieldPreferences = preferences
    }
    
    private func moveField(from source: IndexSet, to destination: Int) {
        preferences.fieldItems.move(fromOffsets: source, toOffset: destination)
        preferences.updateSortOrders()
        savePreferences()
    }
    
    
    private func addField() {
        let customField = CustomOrderField(
            name: fieldName.trimmingCharacters(in: .whitespaces),
            placeholder: fieldName.trimmingCharacters(in: .whitespaces),
            fieldType: .text,
            isRequired: false
        )
        
        self.preferences.addCustomField(customField)
        self.showingAddFieldSheet = false
    }
}


struct DraggableFieldRow: View {
    let fieldItem: OrderFieldItem
    @Binding var preferences: OrderFieldPreferences
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
            
            
            // Tap to edit for custom fields (remove delete button)
            // Custom fields are now editable via tap gesture
            
            
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
                    get: {
                        if let index = preferences.fieldItems.firstIndex(where: { $0.id == fieldItem.id }) {
                            return preferences.fieldItems[index].isVisible
                        }
                        return false
                    },
                    set: { newValue in
                        if let index = preferences.fieldItems.firstIndex(where: { $0.id == fieldItem.id }) {
                            preferences.fieldItems[index].isVisible = newValue
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

struct AddCustomOrderFieldContent: View {
    let editingField: CustomOrderField?
    let onSave: (CustomOrderField) -> Void
    let onDelete: () -> Void
    
    @State private var fieldName = ""
    @State private var isEmpty: Bool = true
    
    private var isEditMode: Bool {
        editingField != nil
    }
    
    private func addField() {
        let newField = CustomOrderField(
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
                
                Text("This will create a text field in your order form")
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
                
                GlobalButton(title: isEditMode ? "Update" : "Save", backgroundColor: Color.appTint) {
                    addField()
                }
                .disabled(isEmpty)
            }
        }
        .onAppear {
            if let editingField = editingField {
                fieldName = editingField.name
                isEmpty = fieldName.trimmingCharacters(in: .whitespaces).isEmpty
            } else {
                fieldName = ""
                isEmpty = true
            }
        }
    }
}

//
//// MARK: - DraggableFieldRow
//struct DraggableFieldRow: View {
//    let fieldItem: OrderFieldItem
//    @Binding var preferences: OrderFieldPreferences
//    
//    var body: some View {
//        let _ = print("[DEBUG ROW] Rendering row for: \(fieldItem.id)")
//        let _ = print("[DEBUG ROW] systemImage: \(fieldItem.systemImage)")
//        let _ = print("[DEBUG ROW] displayName: \(fieldItem.displayName)")
//        let _ = print("[DEBUG ROW] isRequired: \(fieldItem.isRequired)")
//        let _ = print("[DEBUG ROW] isBuiltIn: \(fieldItem.isBuiltIn)")
//        
//        return HStack {
//       
//            
//            // Field icon
//            Image(systemName: fieldItem.systemImage)
//                .foregroundColor(.appTint)
//                .font(.body)
//                
//            
//            // Field info
//            VStack(alignment: .leading, spacing: 2) {
//                HStack {
//                    Text(fieldItem.displayName)
//                        .font(.body)
//                        .foregroundColor(.text)
//                    
//                    if fieldItem.isRequired {
//                        Text("Required")
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal, 6)
//                            .padding(.vertical, 2)
//                            .background(Color.secondary.opacity(0.2))
//                            .cornerRadius(4)
//                    }
//                }
//                
//                if !fieldItem.isBuiltIn {
//                    Text(fieldItem.customField?.fieldType.displayName ?? "")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            Spacer()
//            
//            // Delete button for custom fields
//            if !fieldItem.isBuiltIn {
//                Button {
//                    preferences.removeField(withId: fieldItem.id)
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//                .padding(.trailing, 8)
//            }
//            
//            // Visibility toggle
//            Toggle("", isOn: Binding(
//                get: {
//                    if let index = preferences.fieldItems.firstIndex(where: { $0.id == fieldItem.id }) {
//                        return preferences.fieldItems[index].isVisible
//                    }
//                    return false
//                },
//                set: { newValue in
//                    if let index = preferences.fieldItems.firstIndex(where: { $0.id == fieldItem.id }) {
//                        preferences.fieldItems[index].isVisible = newValue
//                    }
//                }
//            ))
//            .tint(Color.appTint)
//            .disabled(fieldItem.isRequired)
//
//            
//        }
//        .padding(10)
//        .contentShape(Rectangle())
//    }
//}
//


//struct FieldGroupCard<Content: View>: View {
//    let title: String
//    let subtitle: String
//    let icon: String
//    @ViewBuilder let content: Content
//    
//    var body: some View {
//        CustomCardView {
//            VStack(alignment: .leading, spacing: 16) {
//                HStack {
//                    Image(systemName: icon)
//                        .font(.title2)
//                        .foregroundColor(.appTint)
//                    
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text(title)
//                            .font(.headline)
//                            .foregroundColor(.text)
//                        Text(subtitle)
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Spacer()
//                }
//                
//                content
//            }
//        }
//    }
//}
//
//


struct FieldToggleRow: View {
    let title: String
    @Binding var isEnabled: Bool
    var isRequired: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(isRequired ? .text : .text)
            
            if isRequired {
                Text("Required")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .disabled(isRequired)
        }
    }
}



struct PresetRow: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.text)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .cardBackground()
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    OrderFieldSettings()
}



