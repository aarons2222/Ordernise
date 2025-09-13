//
//  OrderCalendar.swift
//  Ordernise
//
//  Created by Aaron Strickland on 18/08/2025.
//

import SwiftUI
import SwiftData

struct OrderCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @Query(sort: \Order.orderReceivedDate, order: .reverse) private var realOrders: [Order]
    @State private var selectedDate = Date()
    @State private var currentMonth: Int = 0
    private let today = Date()
    
    private var allOrders: [Order] {
        if dummyDataManager.isDummyModeEnabled {
            return dummyDataManager.getDummyOrders()
        } else {
            return realOrders
        }
    }
    
    var body: some View {
 
            VStack {
                calendarHeader
                ScrollView(showsIndicators: false){
                    CustomDatePicker(selectedDate: $selectedDate, currentMonth: $currentMonth, orders: allOrders, today: today)
                        .padding()
                        .onChange(of: currentMonth) {
                            // Don't update selectedDate when changing months
                        }
                    
                    
                    Color.clear.frame(height: 60)
                }
                
                
                
                
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
    }
    
    private var calendarHeader: some View {
        HStack(spacing: 0) {
            
            
         

            
            
            let date = getCurrentMonth()
            let headerText = date.formatted(.dateTime.month(.wide).year())

            Text(headerText)
                .font(.title)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .truncationMode(.tail)
                .padding(.horizontal, 5)
                .id(headerText) // forces SwiftUI to treat it as new when the text changes
                .animation(.easeInOut(duration: 0.25), value: headerText)
            
            Spacer()
            
            HStack(spacing: 10){
                Button {
                    withAnimation {
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left.circle")
                        .font(.title)
                        .tint(Color.appTint)
                }
                
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right.circle")
                        .font(.title)
                        .tint(Color.appTint)
                }
            }.padding(.trailing, 10)
            
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // extrating Year And Month for display...
    func extraDate()->[String]{
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate) - 1
        let year = calendar.component(.year, from: selectedDate)
        
        return ["\(year)",calendar.monthSymbols[month]]
    }
    
    func getCurrentMonth()->Date{
        
        let calendar = Calendar.current
        
        // Getting Current Month Date....
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
                
        return currentMonth
    }
}



#Preview {
    OrderCalendarView()
}



//
//  CustomDatePicker.swift
//  ElegantTaskApp (iOS)
//
//  Created by Balaji on 28/09/21.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Int
    let orders: [Order]
    let today: Date
    @StateObject private var localeManager = LocaleManager.shared
    // Sheet presentation
    @State private var selectedOrder: Order?
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            dayLabels
            calendarGrid
            ordersSection
        }
        .fullScreenCover(item: $selectedOrder) { order in
            ZStack{
                Color(.systemBackground)
                       .ignoresSafeArea()
                OrderDetailView(order: order, mode: .view)
            }
        }
        
        
//        .sheet(item: $selectedOrder) { order in
//            NavigationView {
//                OrderInfoSheet(order: order)
//                    .background(colorScheme == .dark ? Color.black : Color.white
//                    )
//
//            }
//        }
    }
    
    private var dayLabels: some View {
        let days: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return HStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 10)
    }
    
    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        return LazyVGrid(columns: columns, spacing: 5) {
            ForEach(extractDate()) { value in
                CardView(value: value)
                    .onTapGesture {
                        selectedDate = value.date
                    }
            }
        }
    }
    
    private var ordersSection: some View {
        VStack(spacing: 15) {
            Text("Orders")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ordersList
        }

    }
    
    @ViewBuilder
    private var ordersList: some View {
        let ordersForDate = orders.filter { order in
            return isSameDay(date1: getDisplayDate(for: order), date2: selectedDate)
        }
        
        if !ordersForDate.isEmpty {
            // Sort orders by priority (urgent first, completed last)
            let sortedOrders = ordersForDate.sorted { order1, order2 in
                let statusPriority: [OrderStatus: Int] = [
                    .failed: 9,
                    .canceled: 9,
                    .returned: 8,
                    .onHold: 7,
                    .refunded: 6,
                    .pending: 5,
                    .received: 4,
                    .processing: 3,
                    .shipped: 2,
                    .delivered: 1,
                    .fulfilled: 1
                ]
                let priority1 = statusPriority[order1.status ?? .received] ?? 0
                let priority2 = statusPriority[order2.status ?? .received] ?? 0
                return priority1 > priority2 // Higher priority first, completed orders last
            }
            
            ForEach(sortedOrders, id: \.id) { order in
                 orderCard(for: order)
                
            }
        } else {
            Text("No Orders Found")
                .foregroundColor(.secondary)
        }
    }
    
    private func orderCard(for order: Order) -> some View {
        
        
        
        HStack(spacing: 0) {
            // Left color bar
            Rectangle()
                .fill((order.status ?? .received).statusColor.gradient)
                .frame(width: 20)
                .frame(minHeight: 25)
                .cornerRadius(50, corners: [.topLeft, .bottomLeft])

            // Right content
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    // Left section
                    VStack(alignment: .leading, spacing: 4) {
                        
                        if let customerName = order.customerName {
                            Text(customerName)
                                .font(.headline)
                           
                        }
                        
                        
                        
                        if let items = order.items, !items.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(items, id: \.id) { item in
                                
                                        
                                        
                                        Text("\(item.quantity) x \(item.stockItem?.name ?? String(localized: "Unnamed Item"))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                      
                                      
                                      
                                    
                                }
                            }
                        }

                        Text((order.platform ?? .amazon).rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        
                   

                        
                    
                    }

                    Spacer()

                    // Right section
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "largecircle.fill.circle")
                            Text((order.status ?? .received).localizedTitle)
                            
                        }
                        .font(.caption)
                        .foregroundStyle((order.status ?? .received).statusColor)

                   

                        Spacer()
                   
                    }
                    .padding(.top, 1)
                }
                
                HStack{
                    Spacer()
                    let totalValue = (order.items ?? []).reduce(0.0) { total, item in
                        total + (item.stockItem?.price ?? 0.0) * Double(item.quantity)
                    }

                    if !(order.items ?? []).isEmpty {
                        Text("\(String(localized: "Order Total: "))\(totalValue, format: localeManager.currencyFormatStyle)")
                            .font(.footnote)
                    }
                 
                }
            }
            .padding()
            .frame(minHeight: 25)
            .background(.thinMaterial)
            .cornerRadius(10, corners: [.topRight, .bottomRight])
        }

        .onTapGesture {
            selectedOrder = order
        }
        
        
        
        


    }
    
    @ViewBuilder
    func CardView(value: DateValue)->some View{
        
        VStack(spacing: 4) {
            
            if value.day != -1{
                
                let hasOrders = orders.contains { order in
                    return isSameDay(date1: getDisplayDate(for: order), date2: value.date)
                }
                
                // Number section - always in same position
                Text("\(value.day)")
                    .font(.title3.weight(.medium))
                    .foregroundColor(
                        isSameDay(date1: value.date, date2: selectedDate) ? Color.text : isSameDay(date1: value.date, date2: today) ? Color.appTint : .text
                    )
                    .frame(width: 32, height: 32)
                   
                    .overlay(
                        Circle()
                            .stroke(Color.appTint, lineWidth: 3)
                            .opacity(isSameDay(date1: value.date, date2: selectedDate) ? 1 : 0)
                    )


                Color.clear.frame(height: 2)
        
                
                VStack(spacing: 4) {
                    if hasOrders {
                        ForEach(getUniqueStatuses(for: value.date), id: \.self) { status in
                            Rectangle()
                                .frame(height: 4)
                                .cornerRadius(30)
                                .foregroundStyle(status.statusColor)
                        }
                    }
                }
                .frame(minHeight: 16, alignment: .top)
      
                Spacer()
            }
        }
        .frame(height: 60, alignment: .center)
    }
    
    // checking dates...
    func isSameDay(date1: Date,date2: Date)->Bool{
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // Get the display date for an order (orderCompletionDate if set, otherwise orderReceivedDate)
    func getDisplayDate(for order: Order) -> Date {
        return order.orderCompletionDate ?? order.orderReceivedDate
    }
    
    // Get unique order statuses for a specific date, sorted by priority
    func getUniqueStatuses(for date: Date) -> [OrderStatus] {
        let ordersForDate = orders.filter { order in
            return isSameDay(date1: getDisplayDate(for: order), date2: date)
        }
        
        guard !ordersForDate.isEmpty else { return [] }
        
        // Define status priority (higher number = higher priority)
        let statusPriority: [OrderStatus: Int] = [
            .failed: 9,
            .canceled: 9,
            .returned: 8,
            .onHold: 7,
            .refunded: 6,
            .pending: 5,
            .received: 4,
            .processing: 3,
            .shipped: 2,
            .delivered: 1,
            .fulfilled: 1
        ]
        
        // Get unique statuses and sort by priority (urgent/attention-needed first, completed last)
        let uniqueStatuses = Array(Set(ordersForDate.map { $0.status ?? .received }))
        return uniqueStatuses.sorted { status1, status2 in
            let priority1 = statusPriority[status1] ?? 0
            let priority2 = statusPriority[status2] ?? 0
            return priority1 > priority2 // Higher priority numbers appear first (top), completed orders (low numbers) at bottom
        }
    }
    
    // Get the highest priority status color for orders on a specific date
    func getMarkerColor(for date: Date) -> Color {
        let ordersForDate = orders.filter { order in
            return isSameDay(date1: getDisplayDate(for: order), date2: date)
        }
        
        guard !ordersForDate.isEmpty else { return Color.appTint }
        
        // Define status priority (higher number = higher priority)
        let statusPriority: [OrderStatus: Int] = [
            .failed: 9,
            .canceled: 9,
            .returned: 8,
            .onHold: 7,
            .refunded: 6,
            .pending: 5,
            .received: 4,
            .processing: 3,
            .shipped: 2,
            .delivered: 1,
            .fulfilled: 1
        ]
        
        // Find the highest priority status
        let highestPriorityStatus = ordersForDate
            .map { $0.status ?? .received }
            .max { status1, status2 in
                let priority1 = statusPriority[status1] ?? 0
                let priority2 = statusPriority[status2] ?? 0
                return priority1 < priority2
            }
        
        return highestPriorityStatus?.statusColor ?? Color.appTint
    }
    
    func getCurrentMonth()->Date{
        
        let calendar = Calendar.current
        
        // Getting Current Month Date....
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
                
        return currentMonth
    }
    
    func extractDate()->[DateValue]{
        
        let calendar = Calendar.current
        
        // Getting Current Month Date....
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            
            // getting day...
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        // adding offset days to get exact week day...
        let firstWeekday = calendar.component(.weekday, from: days.first!.date)
        
        for _ in 0..<firstWeekday - 1{
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
    
}

struct DateValue: Identifiable {
    let id = UUID()
    var day: Int
    var date: Date
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        OrderCalendarView()
    }
}

// Extending Date to get Current Month Dates...
extension Date{
    
    func getAllDates()->[Date]{
        
        let calendar = Calendar.current
        
        // getting start Date...
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        // getting date...
        return range.compactMap { day -> Date in
            
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
