import SwiftUI
import SwiftData

struct StockItemPickerView: View {
    let onSelection: (StockItem, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var stockItems: [StockItem]
    @StateObject private var localeManager = LocaleManager.shared
    @State private var selectedQuantities: [StockItem.ID: Int] = [:]
    
    private func getQuantity(for item: StockItem) -> Int {
        selectedQuantities[item.id] ?? 0
    }
    
    private func setQuantity(for item: StockItem, quantity: Int) {
        let maxAllowed = item.quantityAvailable
        let clamped = min(max(0, quantity), maxAllowed)
        selectedQuantities[item.id] = clamped
    }
    
    private func canIncrement(for item: StockItem) -> Bool {
        let currentQuantity = getQuantity(for: item)
        return currentQuantity < item.quantityAvailable
    }
    
    private func canDecrement(for item: StockItem) -> Bool {
        return getQuantity(for: item) > 0
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderWithButton(
                    title: String(localized: "Select Stock Items"),
                    buttonContent: String(localized: "Done"),
                    isButtonImage: false,
                    showTrailingButton: true,
                    showLeadingButton: true,
                    onButtonTap: {
                        dismiss()
                    }
                )
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(stockItems) { item in
                            StockItemRow(
                                item: item,
                                quantity: getQuantity(for: item),
                                onQuantityChange: { quantity in
                                    setQuantity(for: item, quantity: quantity)
                                },
                                onSelect: {
                                    let quantity = getQuantity(for: item)
                                    if quantity > 0 {
                                        onSelection(item, quantity)
                                        dismiss()
                                    }
                                },
                                canIncrement: canIncrement(for: item),
                                canDecrement: canDecrement(for: item)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .enableSwipeBack()
        }
    }
}

private struct StockItemRow: View {
    let item: StockItem
    let quantity: Int
    let onQuantityChange: (Int) -> Void
    let onSelect: () -> Void
    let canIncrement: Bool
    let canDecrement: Bool
    @StateObject private var localeManager = LocaleManager.shared
    
    private var totalPrice: Double {
        Double(quantity) * item.price
    }
    
    var body: some View {
        CustomCardView {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.text)
                        
                        Text("\(String(localized: "Available")): \(item.quantityAvailable)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(item.price, format: localeManager.currencyFormatStyle)
                            .font(.subheadline)
                            .foregroundColor(.appTint)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if quantity > 0 {
                            Text("\(String(localized: "Total")): \(totalPrice, format: localeManager.currencyFormatStyle)")
                                .font(.subheadline)
                                .foregroundColor(.appTint)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                HStack {
                    // Quantity Controls
                    HStack(spacing: 12) {
                        Button {
                            onQuantityChange(quantity - 1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(canDecrement ? .appTint : .gray)
                        }
                        .disabled(!canDecrement)
                        
                        Text("\(quantity)")
                            .font(.headline)
                            .foregroundColor(.text)
                            .frame(minWidth: 30)
                        
                        Button {
                            onQuantityChange(quantity + 1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(canIncrement ? .appTint : .gray)
                        }
                        .disabled(!canIncrement)
                    }
                    
                    Spacer()
                    
                    // Add Button
                    Button {
                        onSelect()
                    } label: {
                        Text(String(localized: "Add"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(quantity > 0 ? Color.appTint : Color.gray)
                            )
                    }
                    .disabled(quantity == 0)
                }
            }
        }
    }
}

#Preview {
    StockItemPickerView { stockItem, quantity in
        print("Selected: \(stockItem.name), Quantity: \(quantity)")
    }
}
