import SwiftUI

struct OrderItemPickerView: View {
    let stockItems: [StockItem]
    let existingQuantities: [StockItem.ID: Int]
    let onSelection: (StockItem, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.stockManager) private var stockManager
    @StateObject private var localeManager = LocaleManager.shared
    @State private var quantities: [StockItem.ID: Int] = [:]
    
    @State var showAddItem = false
    private func getQuantity(for item: StockItem) -> Int {
        quantities[item.id] ?? 0
    }
    
    private func setQuantity(for item: StockItem, quantity: Int) {
        let alreadyAllocated = existingQuantities[item.id] ?? 0
        let currentQuantity = getQuantity(for: item)
        
        // If we're decreasing quantity, allow it without stock validation
        if quantity < currentQuantity {
            quantities[item.id] = max(0, quantity)
        } else {
            // If we're increasing quantity, validate against available stock
            let maxAllowed = item.quantityAvailable + alreadyAllocated
            let clamped = min(max(0, quantity), maxAllowed)
            quantities[item.id] = clamped
        }
    }
    
    private func canIncrement(for item: StockItem) -> Bool {
        let currentQuantity = getQuantity(for: item)
        let alreadyAllocated = existingQuantities[item.id] ?? 0
        // Can increment if there's still stock available (including what we can reclaim from existing allocation)
        let maxAllowed = item.quantityAvailable + alreadyAllocated
        return currentQuantity < maxAllowed
    }
    
    private func canDecrement(for item: StockItem) -> Bool {
        return getQuantity(for: item) > 0
    }
    
    private var hasSelectedItems: Bool {
        quantities.values.contains { $0 > 0 }
    }
    
    private func availabilityText(for item: StockItem) -> String {
        let currentlySelected = getQuantity(for: item)
        let alreadyAllocated = existingQuantities[item.id] ?? 0
        let pendingAllocation = stockManager?.getItemsWithPendingChanges()[item.id] ?? 0
        // Available = current stock - pending allocations + what we can reclaim from existing allocation
        let availableRemaining = item.quantityAvailable - pendingAllocation + alreadyAllocated - currentlySelected
        return "Available: \(max(0, availableRemaining))"
    }
    
    private func addSelectedItems() {
        // Process all items that have been changed from their existing quantities
        for item in stockItems {
            let currentQuantity = getQuantity(for: item)
            let existingQuantity = existingQuantities[item.id] ?? 0
            
            // Only call onSelection if the quantity has changed
            if currentQuantity != existingQuantity {
                onSelection(item, currentQuantity)
            }
        }
        dismiss()
    }
    
    private func initializeQuantities() {
        // Initialize from existing quantities
        quantities = existingQuantities
    }
    
    var body: some View {
        VStack {
            
            
            
            HeaderWithButton(
                title: "Add Items",
                buttonContent: "Save",
                isButtonImage: false,
                showTrailingButton: true,
                showLeadingButton: true,
                onButtonTap: {
                    addSelectedItems()
                }
            )
            
            ScrollView{
                
                VStack{
                    
                 
                    ForEach(stockItems) { item in
                        
                        CustomCardView {
                            VStack(alignment: .leading, spacing: 8) {
                                
                                // Top Row: Name + Stock Status
                                HStack {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    
                                    
                                    Spacer()
                                }
                                
                                // Second Row: Availability + Price
                                HStack {
                                    Text(availabilityText(for: item))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(item.price, format: localeManager.currencyFormatStyle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                // Third Row: Quantity controls
                                HStack {
                                    Spacer()
                                    HStack(spacing: 12) {
                                        Button {
                                            let currentQty = getQuantity(for: item)
                                            setQuantity(for: item, quantity: currentQty - 1)
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(canDecrement(for: item) ? Color.appTint.opacity(0.8) : .gray)
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(!canDecrement(for: item))
                                        
                                        Text("\(getQuantity(for: item))")
                                            .font(.headline)
                                            .frame(minWidth: 30)
                                        
                                        Button {
                                            let currentQty = getQuantity(for: item)
                                            setQuantity(for: item, quantity: currentQty + 1)
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(canIncrement(for: item) ? Color.appTint : .gray)
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(!canIncrement(for: item))
                                    }
                                }
                                
                                // Fourth Row: Total (if qty > 0)
                                if getQuantity(for: item) > 0 {
                                    HStack {
                                        Text("Total: ")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text((item.price * Double(getQuantity(for: item))), format: localeManager.currencyFormatStyle)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        
                    
                }
                }
                .padding(.horizontal, 20)
            }
            
            .navigationBarBackButtonHidden()
        }
     
        
        .fullScreenCover(isPresented: $showAddItem) {
            StockItemDetailView(mode: .add)
        }
        
        
        .onAppear {
            initializeQuantities()
            
        
            
            if (stockItems.count == 0){
                self.showAddItem = true
            }
        }
    }
}

