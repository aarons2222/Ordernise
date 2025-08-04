import SwiftUI

struct StockItemPickerView: View {
    let stockItems: [StockItem]
    let existingQuantities: [StockItem.ID: Int]
    let onSelection: (StockItem, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var quantities: [StockItem.ID: Int] = [:]
    
    private func getQuantity(for item: StockItem) -> Int {
        quantities[item.id] ?? 0
    }
    
    private func setQuantity(for item: StockItem, quantity: Int) {
        let maxAllowed = item.quantityAvailable
        let clamped = min(max(0, quantity), maxAllowed)
        quantities[item.id] = clamped
    }
    
    private func canIncrement(for item: StockItem) -> Bool {
        let currentQuantity = getQuantity(for: item)
        return currentQuantity < item.quantityAvailable
    }
    
    private func canDecrement(for item: StockItem) -> Bool {
        return getQuantity(for: item) > 0
    }
    
    private var hasSelectedItems: Bool {
        quantities.values.contains { $0 > 0 }
    }
    
    private func addSelectedItems() {
        for item in stockItems {
            let quantity = getQuantity(for: item)
            let originalQuantity = existingQuantities[item.id] ?? 0
            
            // Call callback if quantity has changed from original
            if quantity != originalQuantity {
                onSelection(item, quantity)
            }
        }
        dismiss()
    }
    
    private func initializeQuantities() {
        // First, set all items to 0
        for item in stockItems {
            quantities[item.id] = 0
        }
        
        // Then, set quantities from existing order
        for (stockItemId, quantity) in existingQuantities {
            quantities[stockItemId] = quantity
        }
    }
    
    var body: some View {
        NavigationStack {
            List(stockItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            HStack {
                                Text("Available: \(item.quantityAvailable - getQuantity(for: item))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(item.price, format: .currency(code: item.currency.rawValue.uppercased()))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    
                    HStack {
                       
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Decrement Button
                            Button {
                                let currentQty = getQuantity(for: item)
                                setQuantity(for: item, quantity: currentQty - 1)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(canDecrement(for: item) ? .blue : .gray)
                            }
                            .buttonStyle(.plain)
                            .disabled(!canDecrement(for: item))
                            
                            Text("\(getQuantity(for: item))")
                                .font(.headline)
                                .frame(minWidth: 30)
                            
                            // Increment Button  
                            Button {
                                let currentQty = getQuantity(for: item)
                                setQuantity(for: item, quantity: currentQty + 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(canIncrement(for: item) ? .blue : .gray)
                            }
                            .buttonStyle(.plain)
                            .disabled(!canIncrement(for: item))
                        }
                        

                    }
                    
                    if getQuantity(for: item) > 0 {
                        HStack {
                            Text("Total: ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text((item.price * Double(getQuantity(for: item))), format: .currency(code: item.currency.rawValue.uppercased()))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Select Stock Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addSelectedItems()
                    }
               
                }
            }
        }
        .onAppear {
            initializeQuantities()
        }
    }
}
