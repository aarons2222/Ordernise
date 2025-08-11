import SwiftUI
import SwiftData

struct StockList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StockItem.name, order: .forward) private var stockItems: [StockItem]
    
    @State private var showingAddStock = false
    @State private var confirmDelete = false
    @State private var selectedStockItem: StockItem?
    @State private var itemToDelete: StockItem?
    @Binding var searchText: String
    
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
                headerSection
               // searchSection
                mainContentView
            }
            .fullScreenCover(isPresented: $showingAddStock) {
                StockItemDetailView(mode: .add)
            }
            .fullScreenCover(item: $selectedStockItem) { selectedItem in
                StockItemDetailView(stockItem: selectedItem, mode: .view)
            }
            
            .alert("Confirm deletion", isPresented: $confirmDelete, actions: {
                
                /// A destructive button that appears in red.
                Button(role: .destructive) {
                    if let item = itemToDelete {
                        deleteItem(item)
                    }
                } label: {
                    Text("Delete")
                }
                
                /// A cancellation button that appears with bold text.
                Button("Cancel", role: .cancel) {
                    // Perform cancellation
                }
                
          
            }, message: {
                Text("This action cannot be undone")
            })
        }
    }
    
    private var headerSection: some View {
   
        
        
        HeaderWithButton(
            title: "Stock",
            buttonContent: "plus.circle",
            isButtonImage: true,
            showTrailingButton: true,
            showLeadingButton: false,
            onButtonTap: {
           
                showingAddStock = true
            }
        )
    }
    
    private var searchSection: some View {
        CustomSearchBar(searchText: $searchText) { status in
            
        }
    }
    
    private var mainContentView: some View {
        Group {
            if stockItems.isEmpty {
                Spacer()
                ContentUnavailableView("No Stock Items", systemImage: "shippingbox", description: Text("Tap \(Image(systemName: "plus.circle")) to add your first item.."))
                Spacer()
            } else if filteredItems.isEmpty {
                Spacer()
                ContentUnavailableView("No Results", systemImage: "magnifyingglass", description: Text("No stock items match your search."))
                Spacer()
            } else {
                stockListView
            }
        }
    }
    
    private var stockListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedItems, id: \.0) { groupName, items in
                    Section(header: sectionHeader(groupName)) {
                        ForEach(items) { item in
                            stockItemRow(item)
                        }
                    }
                }
            }
        }
    }
    
    private func stockItemRow(_ item: StockItem) -> some View {
        StockItemCard(item: item, height: 50)
        
         
            .swipeActions {
                Action(symbolImage: "trash.fill", tint: .white, background: .red) { reset in
                    if filteredItems.contains(where: { $0.id == item.id }) {
                        itemToDelete = item
                        confirmDelete = true
                    }
                    reset = true
                }
            }
            .onTapGesture {
                selectedStockItem = item
            }
    }
    
    private func sectionHeader(_ groupName: String) -> some View {
        HStack {
            Text(groupName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
      
    }

    
    private func deleteItems(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = filteredItems[index]
                modelContext.delete(item)
            }
        }
    }
    
    private func deleteItem(_ item: StockItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }
    
    private func deleteItemsFromGroup(at offsets: IndexSet, in items: [StockItem]) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}




