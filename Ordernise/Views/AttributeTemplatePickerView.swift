//
//  AttributeTemplatePickerView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct AttributeTemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let templates: [AttributeTemplate]
    let onTemplateSelected: (AttributeTemplate) -> Void
    
    @State private var selectedTemplate: AttributeTemplate?
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: AttributeTemplate?
    
    var body: some View {
        NavigationStack {
            List {
                if templates.isEmpty {
                    ContentUnavailableView(
                        "No Templates",
                        systemImage: "tray",
                        description: Text("Create templates by saving custom attributes from items")
                    )
                } else {
                    ForEach(templates, id: \.id) { template in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(template.name)
                                            .font(.headline)
                                        if template.isDefault {
                                            Text("DEFAULT")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.appTint)
                                                .foregroundColor(.white)
                                                .cornerRadius(4)
                                        }
                                    }
                                    Text("\(template.attributes.count) attribute\(template.attributes.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 4) {
                                    Button("Use") {
                                        onTemplateSelected(template)
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button(template.isDefault ? "Remove Default" : "Set Default") {
                                        toggleDefault(template)
                                    }
                                    .font(.caption)
                                    .buttonStyle(.plain)
                                    .foregroundColor(template.isDefault ? .red : Color.appTint)
                                }
                            }
                            
                            // Show preview of attributes
                            if !template.attributes.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(Array(template.attributes.keys.sorted()), id: \.self) { key in
                                        HStack {
                                            Text("\(key):")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(template.attributes[key] ?? "")
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .padding(.leading, 16)
                            }
                        }
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                templateToDelete = template
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Attribute Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Delete Template", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let template = templateToDelete {
                    deleteTemplate(template)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this template? This action cannot be undone.")
        }
    }
    
    private func toggleDefault(_ template: AttributeTemplate) {
        // If setting as default, remove default from other templates of the same type
        if !template.isDefault {
            let otherTemplates = templates.filter { $0.templateType == template.templateType && $0.id != template.id }
            for otherTemplate in otherTemplates {
                otherTemplate.isDefault = false
            }
        }
        
        // Toggle the default status
        template.isDefault.toggle()
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to update template default status: \(error)")
        }
    }
    
    private func deleteTemplate(_ template: AttributeTemplate) {
        modelContext.delete(template)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete template: \(error)")
        }
        
        templateToDelete = nil
    }
}

#Preview {
    let previewTemplates = [
        AttributeTemplate(
            name: "Basic Info",
            attributes: ["SKU": "ABC123", "Brand": "Sample Brand"],
            templateType: .stockItem
        ),
        AttributeTemplate(
            name: "Shipping Details",
            attributes: ["Weight": "1.5kg", "Dimensions": "10x10x5cm"],
            templateType: .stockItem
        )
    ]
    
    return AttributeTemplatePickerView(
        templates: previewTemplates,
        onTemplateSelected: { _ in }
    )
}
