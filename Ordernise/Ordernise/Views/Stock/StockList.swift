import SwiftUI
import SwiftData

struct StockList: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @Query(sort: \StockItem.name) private var realStockItems: [StockItem]
    
    private var allStockItems: [StockItem] {
        if dummyDataManager.isDummyModeEnabled {
            return dummyDataManager.getDummyStockItems()
        } else {
            return realStockItems
        }
    }
    
    @State private var showingAddStock = false
    @State private var confirmDelete = false
    @State private var selectedStockItem: StockItem?
    @State private var itemToDelete: StockItem?
    @Binding var searchText: String
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    
    enum StockSortOption: String, CaseIterable, Identifiable {
        case alphabetical = "Name"
        case category = "Category"
        case price = "Price (Low to High)"
        case quantity = "Quantity (Low to High)"
        
        var id: String { rawValue }
        
        // Localized display name for UI
        var localizedTitle: String {
            switch self {
            case .alphabetical:
                return String(localized: "Name")
            case .category:
                return String(localized: "Category")
            case .price:
                return String(localized: "Price (Low to High)")
            case .quantity:
                return String(localized: "Quantity (Low to High)")
            }
        }
    }
    @AppStorage("stockListSortOption") private var currentSortOption: StockSortOption = .alphabetical

    
    var filteredItems: [StockItem] {
        // Filter by search text
        let filtered = searchText.isEmpty ? allStockItems : allStockItems.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText) ||
            item.category?.name.localizedCaseInsensitiveContains(searchText) == true
        }

        // Sort based on current option
        switch currentSortOption {
        case .alphabetical:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .category:
            return filtered.sorted {
                let c0 = $0.category?.name ?? ""
                let c1 = $1.category?.name ?? ""
                return c0.localizedCaseInsensitiveCompare(c1) == .orderedAscending
            }
        case .price:
            return filtered.sorted { $0.price < $1.price }
        case .quantity:
            return filtered.sorted { $0.quantityAvailable < $1.quantityAvailable }
        }
    }

  
    
    var groupedItems: [(String, [StockItem])] {
        switch currentSortOption {
        case .alphabetical:
            let grouped = Dictionary(grouping: filteredItems) { item in
                String(item.name.prefix(1).uppercased())
            }
            return grouped.sorted { $0.key < $1.key }
            
        case .category:
            let grouped = Dictionary(grouping: filteredItems) { item in
                item.category?.name ?? String(localized: "No Category")
            }
            return grouped.sorted { $0.key < $1.key }
            
        case .price:
            let grouped = Dictionary(grouping: filteredItems) { item in
                getPriceRangeGroup(for: item.price)
            }
            return grouped.sorted { priceRangeOrder($0.key) < priceRangeOrder($1.key) }
            
        case .quantity:
            let grouped = Dictionary(grouping: filteredItems) { item in
                getQuantityRangeGroup(for: item.quantityAvailable)
            }
            return grouped.sorted { quantityRangeOrder($0.key) < quantityRangeOrder($1.key) }
        }
    }
    
    private func getPriceRangeGroup(for price: Double) -> String {
        switch price {
        case 0..<10: return "£0 - £9.99"
        case 10..<25: return "£10 - £24.99"
        case 25..<50: return "£25 - £49.99"
        case 50..<100: return "£50 - £99.99"
        case 100..<250: return "£100 - £249.99"
        case 250..<500: return "£250 - £499.99"
        default: return "£500+"
        }
    }
    
    private func getQuantityRangeGroup(for quantity: Int) -> String {
        switch quantity {
        case 0...0: return "Out of Stock"
        case 1...10: return "1 - 10 items"
        case 11...25: return "11 - 25 items"
        case 26...50: return "26 - 50 items"
        case 51...100: return "51 - 100 items"
        default: return "100+ items"
        }
    }
    
    private func priceRangeOrder(_ range: String) -> Int {
        switch range {
        case "£0 - £9.99": return 0
        case "£10 - £24.99": return 1
        case "£25 - £49.99": return 2
        case "£50 - £99.99": return 3
        case "£100 - £249.99": return 4
        case "£250 - £499.99": return 5
        case "£500+": return 6
        default: return 7
        }
    }
    
    private func quantityRangeOrder(_ range: String) -> Int {
        switch range {
        case "Out of Stock": return 0
        case "1 - 10 items": return 1
        case "11 - 25 items": return 2
        case "26 - 50 items": return 3
        case "51 - 100 items": return 4
        case "100+ items": return 5
        default: return 6
        }
    }

    @State var showPaywall: Bool = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
          
          
                    if allStockItems.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            String(localized: "No Stock Items"),
                            systemImage: "shippingbox",
                            description: Text(String(localized: "Tap ")) +
                                        Text(Image(systemName: "plus.circle")) +
                                        Text(String(localized: " to add your first item.."))
                        )
                        Spacer()
                    } else if filteredItems.isEmpty {
                        Spacer()
                        ContentUnavailableView(String(localized: "No Results"), systemImage: "magnifyingglass", description: Text(String(localized: "No stock items match your search.")))
                        Spacer()
                    } else {
                        
              
                       stockListView
                        
                   
                    }
                
         
            }
            .background(Color(.systemBackground))
            
            .sheet(isPresented: $showPaywall) {
                PaywallView()
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
                

                Button("Cancel", role: .cancel) {

                }
                
          
            }, message: {
                Text("This action cannot be undone")
            })
        }
    }
    
    private var headerSection: some View {
        
        
        HStack(alignment: .center) {
        
         
            
            
            Text(String(localized: "Stock"))
                .font(.title)
                .padding(.horizontal,  15)
            
            Spacer()
            
            
            
            
            
            
            // Sorting menu
              Menu {
                  Picker("Sort by", selection: $currentSortOption) {
                      ForEach(StockSortOption.allCases) { option in
                          Text(option.localizedTitle).tag(option)
                      }
                  }
              } label: {
                  Image(systemName: "arrow.up.arrow.down.circle")
                      .font(.title)
                      .foregroundColor(.appTint)
              }
              .padding(.trailing, 8)
            
            

                Button(action: {
                    if allStockItems.count >= 5 && !subscriptionManager.isSubscribed {
                        showPaywall = true
                    } else {
                        
                        
                        
                        
                        showingAddStock = true
                        
                    }
                    
                }) {
           
                        Image(systemName: "plus.circle")
                            .font(.title)
                            .foregroundColor(.appTint)
                  
                }
                .padding(.trailing)
            
        }
        .frame(height: 50)

    }

    

    
    private var stockListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(groupedItems, id: \.0) { groupName, items in
                    sectionHeader(groupName)
                        .padding(.horizontal, 10)
                    ForEach(items) { item in
                        stockItemRow(item)
                        Color.clear.frame(height: 10)
                    }
                }
            }
        }
        .contentMargins(.top, 0, for: .scrollContent)

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
        
        
        SectionHeader(title: groupName)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
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




