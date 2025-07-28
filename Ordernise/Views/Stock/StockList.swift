import SwiftUI
import SwiftData

struct StockList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stockItems: [StockItem]
    
    @State private var showingAddStock = false
    @State private var selectedStockItem: StockItem?
    @State private var searchText = ""
    
    var filteredItems: [StockItem] {
        stockItems.filter { item in
            searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var groupedItems: [(String, [StockItem])] {
        let grouped = Dictionary(grouping: filteredItems) { item in
            String(item.name.prefix(1).uppercased())
        }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HeaderWithButton(
                    title: "Stock",
                    buttonImage: "plus.circle",
                    showButton: true
                ) {
                    showingAddStock = true
                }
                
                
                CustomSearchBar(searchText: $searchText) { status in
                    
                }
             
             

                if stockItems.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Stock Items", systemImage: "shippingbox", description: Text("Tap + to add your first item."))
                    Spacer()
                } else if filteredItems.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass", description: Text("No stock items match your search."))
                    Spacer()
                } else {
                    List {
                        ForEach(groupedItems, id: \.0) { groupName, items in
                            Section(groupName) {
                                ForEach(items) { item in
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                        HStack {
                                            Text("Qty: \(item.quantityAvailable)")
                                                .font(.caption)
                                                .foregroundColor(item.quantityAvailable == 0 ? .red : item.quantityAvailable <= 10 ? .orange : .secondary)
                                            Spacer()
                                            Text(item.price, format: .currency(code: item.currency.rawValue.uppercased()))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedStockItem = item
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteItemsFromGroup(at: indexSet, in: items)
                                }
                            }
                        }
                    }
                   
                }
            }
            .sheet(isPresented: $showingAddStock) {
                StockItemDetailView(mode: .add)
            }
            .sheet(item: $selectedStockItem) { selectedItem in
                StockItemDetailView(stockItem: selectedItem, mode: .view)
            }
          
        }
       
        
    }

    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredItems[$0] }
        for item in itemsToDelete {
            modelContext.delete(item)
        }
    }
    
    private func deleteItemsFromGroup(at offsets: IndexSet, in items: [StockItem]) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}






