import SwiftUI

struct OrderItemPickerView: View {
    let stockItems: [StockItem]
    let existingQuantities: [StockItem.ID: Int]
    let onSelection: (StockItem, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localeManager = LocaleManager.shared
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
            if quantity > 0 {
                onSelection(item, quantity)
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
                        
                        CustomCardView{
                        
                        
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
                                        
                                        Text(item.price, format: localeManager.currencyFormatStyle)
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
                                            .foregroundColor(canDecrement(for: item) ? Color.appTint.opacity(0.8) : .gray)
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
                                            .foregroundColor(canIncrement(for: item) ? Color.appTint : .gray)
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
                                    Text((item.price * Double(getQuantity(for: item))), format: localeManager.currencyFormatStyle)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                
                            
                            }
                        }
                        .padding(.vertical, 4)
                        
                    }
            }
            
        }
                .padding(.horizontal, 20)
    }
            
            .navigationBarBackButtonHidden()
//            .navigationTitle("Select Stock Items")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        addSelectedItems()
//                    }
//               
//                }
//            }
        }
        .onAppear {
            initializeQuantities()
        }
    }
}
