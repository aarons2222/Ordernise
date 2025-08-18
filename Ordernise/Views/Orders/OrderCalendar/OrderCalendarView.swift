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
                }
                
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
    }
    
    private var calendarHeader: some View {
        HStack(spacing: 0) {
            
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.backward.circle")
                    .font(.title)
                    .foregroundColor(.appTint)
                    .padding(.leading)
            }
            
            
            let dateComponents = extraDate()

            Text("\(dateComponents[1]) \(dateComponents[0])")
                .font(.title)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .truncationMode(.tail)
                .padding(.horizontal,  5)
            
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
    
    var body: some View {
        VStack(spacing: 0) {
            dayLabels
            calendarGrid
            ordersSection
        }
        .sheet(item: $selectedOrder) { order in
            NavigationView {
                OrderInfoSheet(order: order)
            }
        }
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
        .padding(.top, 5)
    }
    
    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        return LazyVGrid(columns: columns, spacing: 5) {
            ForEach(extractDate()) { value in
                CardView(value: value)
                    .background(
                        Capsule()
                            .fill(Color.appTint.gradient)
                            .padding(.horizontal, 8)
                            .opacity(isSameDay(date1: value.date, date2: selectedDate) ? 1 : 0)
                    )
                  
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
            ForEach(ordersForDate, id: \.id) { order in
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
                .fill(order.status.statusColor.gradient)
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
                        
                        
                        
                        if !order.items.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(order.items, id: \.id) { item in
                                
                                        
                                        
                                        Text("\(item.quantity) x \(item.stockItem?.name ?? String(localized: "Unnamed Item"))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                      
                                      
                                      
                                    
                                }
                            }
                        }

                        Text(order.platform.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        
                   

                        
                    
                    }

                    Spacer()

                    // Right section
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "largecircle.fill.circle")
                            Text(order.status.localizedTitle)
                            
                        }
                        .font(.caption)
                        .foregroundStyle(order.status.statusColor)

                   

                        Spacer()
                   
                    }
                    .padding(.top, 1)
                }
                
                HStack{
                    Spacer()
                    let totalValue = order.items.reduce(0.0) { total, item in
                        total + (item.stockItem?.price ?? 0.0) * Double(item.quantity)
                    }

                    if !order.items.isEmpty {
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
        
        
        
        
        
        
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(order.orderReceivedDate, style: .time)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Spacer()
//                
//                Text(order.status.rawValue)
//                    .font(.caption)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 2)
//                    .background(order.status.statusColor.opacity(0.2))
//                    .foregroundColor(order.status.statusColor)
//                    .cornerRadius(4)
//            }
//            
//            if let customerName = order.customerName {
//                Text(customerName)
//                    .font(.title3.bold())
//            }
//            
//            if let orderRef = order.orderReference {
//                Text("Ref: \(orderRef)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            
//            Text("\(order.items.count) item(s)")
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            Color.appTint
//                .opacity(0.1)
//                .cornerRadius(10)
//        )

    }
    
    @ViewBuilder
    func CardView(value: DateValue)->some View{
        
        VStack{
            
            if value.day != -1{
                
                let hasOrders = orders.contains { order in
                    return isSameDay(date1: getDisplayDate(for: order), date2: value.date)
                }
                
           
                    Spacer()
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(
                            isSameDay(date1: value.date, date2: selectedDate) ? .white : isSameDay(date1: value.date, date2: today) ? Color.appTint : .primary
                        )
                        .frame(maxWidth: .infinity)
                Spacer()
                    // Always reserve space for the marker
                    if hasOrders {
                        Image(systemName: "largecircle.fill.circle")
                            .foregroundStyle(
                                isSameDay(date1: value.date, date2: today) ? getMarkerColor(for: value.date) : getMarkerColor(for: value.date)
                            )
                            .frame(width: 6, height: 6)
                    } else {
                        // Invisible placeholder to keep spacing consistent
                        Color.clear
                            .frame(width: 6, height: 6)
                    }
                
                Spacer()
    
//                }
//                else{
//                    
//                    Text("\(value.day)")
//                        .font(.title3.bold())
//                        .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary)
//                        .frame(maxWidth: .infinity)
//                    
//       
//                }
            }
        }
        .padding(.bottom,9)
        .frame(height: 60,alignment: .top)
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
            .map(\.status)
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
