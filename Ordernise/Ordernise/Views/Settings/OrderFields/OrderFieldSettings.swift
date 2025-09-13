//
//  StockFieldSettings.swift
//  Ordernise
//
//  Created by Aaron Strickland on 10/08/2025.
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
    
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State var showPaywall: Bool = false


    init() {
        let prefs = UserDefaults.standard.orderFieldPreferences
        self._preferences = State(initialValue: prefs)
    }
    
    var body: some View {
        VStack {
            HeaderWithButton(
                title: String(localized: "Order Fields"),
                buttonContent: "plus.circle",
                isButtonImage: true,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    
                    if subscriptionManager.isSubscribed {
                        showingAddFieldSheet = true
                    }else{
                        showPaywall = true
                    }
                }
            )
            
  
          
                    // Instructions
         
                            
                            
                            
                            let allFields = preferences.allFieldsInOrder
                            let _ = print("[DEBUG ORDER FOREACH] About to render \(allFields.count) fields")
                            let _ = allFields.enumerated().forEach { index, item in
                                if let builtIn = item.builtInField {
                                    print("[DEBUG ORDER FOREACH] Field[\(index)]: \(builtIn.rawValue) - ID: \(item.id)")
                                }
                            }
                            
                            
                        

                            List {
                                
                            
                                    CustomCardView {
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Image(systemName: "info.circle")
                                                    .foregroundColor(.appTint)
                                                Text("Customise Your Order Item Form")
                                                    .font(.headline)
                                                    .foregroundColor(.text)
                                                Spacer()
                                            }.padding(.bottom, 5)
                                            
                                            
                                            VStack(alignment: .leading, spacing: 5){
                                                Text("• \(String(localized: "Drag to reorder fields"))")
                                                Text("• \( String(localized: "Toggle visibility on/off"))")
                                                Text("• \(   String(localized: "Add custom fields with the + button"))")
                                                Text("• \(String(localized: "Required fields cannot be hidden"))")
                                            }
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                    }.padding(-15)
                                
                                    
                                  
                                  
                              
                                    
                                 
                                    
                                    
                          
                                Section {
                                    
                                ForEach(allFields, id: \.id) { fieldItem in
                                    DraggableOrderFieldRow(
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
                                
                                } header: {
                                    SectionHeader(title: String(localized: "Field Order & Visibility"))
                                        .textCase(nil)
                                }
                                
                            }.scrollIndicators(.hidden)
                           
                            .listRowSpacing(10)
                            .scrollContentBackground(.hidden)
                            .padding(.top, -10)
                                
                                
                    
            Color.clear.frame(height: 30)
                
                        
                
               
            
            
        }
        .toolbar(.hidden)
        

        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    
        .onAppear {
            // Reload preferences from UserDefaults to ensure changes are reflected
            preferences = UserDefaults.standard.orderFieldPreferences
            
            print("[DEBUG ORDER] Raw fieldItems count: \(preferences.fieldItems.count)")
            for (index, item) in preferences.fieldItems.enumerated() {
                if let builtIn = item.builtInField {
                    print("[DEBUG ORDER] fieldItems[\(index)]: \(builtIn.rawValue) - sortOrder: \(item.sortOrder) - visible: \(item.isVisible)")
                } else if let custom = item.customField {
                    print("[DEBUG ORDER] fieldItems[\(index)]: custom_\(custom.name) - sortOrder: \(item.sortOrder) - visible: \(item.isVisible)")
                }
            }
            
            print("[DEBUG ORDER] allFieldsInOrder count: \(preferences.allFieldsInOrder.count)")
            for (index, item) in preferences.allFieldsInOrder.enumerated() {
                if let builtIn = item.builtInField {
                    print("[DEBUG ORDER] allFieldsInOrder[\(index)]: \(builtIn.rawValue) - isVisible: \(item.isVisible)")
                } else if let custom = item.customField {
                    print("[DEBUG ORDER] allFieldsInOrder[\(index)]: custom_\(custom.name) - isVisible: \(item.isVisible)")
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
    
    private func applyPreset(_ preset: OrderFieldPreferences) {
        preferences = preset
        savePreferences()
    }
    
    private func moveField(from source: IndexSet, to destination: Int) {
        preferences.fieldItems.move(fromOffsets: source, toOffset: destination)
        preferences.updateSortOrders()
        savePreferences()
    }
    
    private func savePreferences() {
        UserDefaults.standard.orderFieldPreferences = preferences
    }
}

struct DraggableOrderFieldRow: View {
    let fieldItem: OrderFieldItem
    @Binding var preferences: OrderFieldPreferences
    let onTap: () -> Void

    var body: some View {
        HStack {
            
            
            // Field icon
            Image(systemName: fieldItem.systemImage)
                .foregroundColor(.appTint)
                .font(.title2)
                
            
      
            Text(fieldItem.displayName)
                        .font(.body)
                        .foregroundColor(.text)
                        .layoutPriority(1)
                        .minimumScaleFactor(0.1)

            
            
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
                            UserDefaults.standard.orderFieldPreferences = preferences
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
            isRequired: false
        )
        onSave(newField)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Field Name")
                    .font(.body)
                    .fontWeight(.regular)
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
                
                Text("This will create a text field in your order item form")
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


