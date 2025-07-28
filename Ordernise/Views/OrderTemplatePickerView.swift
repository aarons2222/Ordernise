//
//  OrderTemplatePickerView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct OrderTemplatePickerView: View {
    let templates: [OrderTemplate]
    let onTemplateSelected: (OrderTemplate) -> Void
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: OrderTemplate?
    
    var body: some View {
        NavigationStack {
            List {
                if templates.isEmpty {
                    ContentUnavailableView(
                        "No Order Templates",
                        systemImage: "tray",
                        description: Text("Create your first order template by filling out an order form and tapping 'Save Order as Template'")
                    )
                } else {
                    ForEach(templates) { template in
                        OrderTemplateRow(
                            template: template,
                            onSelect: {
                                onTemplateSelected(template)
                                dismiss()
                            },
                            onToggleDefault: {
                                toggleDefault(template)
                            },
                            onDelete: {
                                templateToDelete = template
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("Order Templates")
            .navigationBarTitleDisplayMode(.large)
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
    
    private func toggleDefault(_ template: OrderTemplate) {
        if template.isDefault {
            // Remove default status
            template.isDefault = false
        } else {
            // Remove default from all other templates first
            for otherTemplate in templates {
                otherTemplate.isDefault = false
            }
            // Set this one as default
            template.isDefault = true
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to update template default status: \(error)")
        }
    }
    
    private func deleteTemplate(_ template: OrderTemplate) {
        modelContext.delete(template)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete template: \(error)")
        }
    }
}

struct OrderTemplateRow: View {
    let template: OrderTemplate
    let onSelect: () -> Void
    let onToggleDefault: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Template name and default badge
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.headline)
                    
                    Text("Created \(template.dateCreated, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if template.isDefault {
                    Text("DEFAULT")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            
            // Template preview
            VStack(alignment: .leading, spacing: 4) {
                Label("Platform: \(template.platform.rawValue)", systemImage: "globe")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("Status: \(template.status.rawValue.capitalized)", systemImage: "flag")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !template.customAttributes.isEmpty {
                    Label("\(template.customAttributes.count) custom attributes", systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Label("No custom attributes", systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            
            // Action buttons
            HStack {
                Button(action: onSelect) {
                    HStack {
                        Image(systemName: "tray.and.arrow.down")
                        Text("Use Template")
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: onToggleDefault) {
                    HStack {
                        Image(systemName: template.isDefault ? "star.fill" : "star")
                        Text(template.isDefault ? "Remove Default" : "Set Default")
                    }
                    .foregroundColor(.orange)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sampleTemplate = OrderTemplate(
        name: "Standard Amazon Order",
        status: .pending,
        platform: .amazon,
        customAttributes: ["Notes": "Rush order", "Gift": "Yes"]
    )
    
    return OrderTemplatePickerView(
        templates: [sampleTemplate],
        onTemplateSelected: { _ in }
    )
}
