//
//  OrderInfoSheet.swift
//  Ordernise
//
//  Created by Aaron Strickland on 18/08/2025.
//

import SwiftUI
internal import Combine

struct OrderInfoSheet: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var currentTime = Date()
    
  @StateObject private var localeManager = LocaleManager.shared

    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                Text("Order Info")
                    .font(.title)
                                 
                Spacer()
                
                Image(systemName: "multiply.circle")
                    .font(.title)
                    .foregroundStyle(Color.appTint.opacity(0.8))
                    .onTapGesture {
                       dismiss()
                    }
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                
                // Main content sections
                VStack(spacing: 16) {
                    orderSummarySection
                    
                    if order.orderCompletionDate != nil {
                        countdownSection
                    }
                    
                    itemsSection
                    
                    HStack(spacing: 12) {
                        platformSection
                        if order.deliveryMethod != nil {
                            deliverySection
                        }
                    }
                    
                    if order.shippingMethod != nil || order.trackingReference != nil {
                        shippingSection
                    }
                    
                    financialSection
                    
                    if !order.attributes.isEmpty {
                        customAttributesSection
                    }
                    
                    if let notes = order.additionalCostNotes, !notes.isEmpty {
                        notesSection
                    }
                }
                
                    Spacer(minLength: 20)
                }
                .padding()
            }
            
            Spacer()
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
    
    
    private var orderSummarySection: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(Color.appTint)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let orderRef = order.orderReference {
                            Text("Order #\(orderRef)")
                                .font(.headline.bold())
                        } else {
                            Text("Order")
                                .font(.headline.bold())
                        }
                        
                        Text(order.orderReceivedDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "largecircle.fill.circle")
                        Text(order.status.localizedTitle)
                        
                    }
                    .font(.caption)
                    .foregroundStyle(order.status.statusColor)
                    
                  
                }
                
                if let customerName = order.customerName {
                    Divider()
                    
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.appTint)
                        Text(customerName)
                            .font(.body.bold())
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var countdownSection: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completion Countdown")
                            .font(.headline.bold())
                        Text("Time until completion date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                if let completionDate = order.orderCompletionDate {
                    let timeRemaining = completionDate.timeIntervalSince(currentTime)
                    
                    if timeRemaining > 0 {
                        VStack(spacing: 8) {
                            Text(formatCountdown(timeRemaining))
                                .font(.title2.bold().monospacedDigit())
                                .foregroundColor(.orange)
                            
                            Text("until \(completionDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.orange.opacity(0.1))
                        )
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            Text("Completion date has passed")
                                .font(.body.bold())
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.green.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
    
    private var itemsSection: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cube.box")
                        .foregroundColor(Color.appTint)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Order Items")
                            .font(.headline.bold())
                        Text("\(order.items.count) items • Total: \(order.itemsTotal.formatted(localeManager.currencyFormatStyle))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                ForEach(order.items, id: \.id) { item in
                    itemRow(item)
                }
            }
        }
    }
    
    private func itemRow(_ item: OrderItem) -> some View {
        HStack {
            // Item icon
            Image(systemName: "tag")
                .foregroundColor(.secondary)
                .font(.caption)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.stockItem?.name ?? "Unknown Item")
                    .font(.body)
                HStack(spacing: 12) {
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let price = item.stockItem?.price {
                        Text("@\(price.formatted(localeManager.currencyFormatStyle))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if let price = item.stockItem?.price {
                    let total = price * Double(item.quantity)
                    Text("\(total.formatted(localeManager.currencyFormatStyle))")
                        .font(.body.bold())
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    private var platformSection: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                    Text("Platform")
                        .font(.headline.bold())
                }
                
                Text(order.platform.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }
    
    @ViewBuilder
    private var deliverySection: some View {
        if let deliveryMethod = order.deliveryMethod {
            CustomCardView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.green)
                        Text("Delivery")
                            .font(.headline.bold())
                    }
                    
                    Text(deliveryMethod.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var shippingSection: some View {
        if order.shippingMethod != nil || order.trackingReference != nil {
            CustomCardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "shippingbox")
                            .foregroundColor(.purple)
                            .font(.title2)
                        Text("Shipping Information")
                            .font(.headline.bold())
                    }
                    
                    if let shippingMethod = order.shippingMethod, !shippingMethod.isEmpty {
                        HStack {
                            Text("Method:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text(shippingMethod)
                                .font(.body)
                        }
                    }
                    
                    if let trackingReference = order.trackingReference, !trackingReference.isEmpty {
                        HStack {
                            Text("Tracking:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text(trackingReference)
                                .font(.body.monospaced())
                        }
                    }
                    
                    if order.shippingCost > 0 {
                        HStack {
                            Text("Cost:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(order.shippingCost.formatted(localeManager.currencyFormatStyle))
                                .font(.body.bold())
                        }
                    }
                }
            }
        }
    }
    
    private var financialSection: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: localeManager.currencySymbolName)
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Financial Summary")
                        .font(.headline.bold())
                }
                
                VStack(spacing: 8) {
                    financialRow("Items Total", value: order.itemsTotal)
                    
                    if order.customerShippingCharge > 0 {
                        financialRow("Customer Shipping", value: order.customerShippingCharge)
                    }
                    
                    if order.shippingCost > 0 {
                        financialRow("Shipping Cost", value: -order.shippingCost, isNegative: true)
                    }
                    
                    if order.sellingFees > 0 {
                        financialRow("Selling Fees", value: -order.sellingFees, isNegative: true)
                    }
                    
                    if order.additionalCosts > 0 {
                        financialRow("Additional Costs", value: -order.additionalCosts, isNegative: true)
                    }
                    
                    Divider()
                    
                    financialRow("Net Profit", value: order.calculatedProfit, isBold: true)
                }
            }
        }
    }
    
    private func financialRow(_ title: String, value: Double, isNegative: Bool = false, isBold: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(isBold ? .body.bold() : .body)
                .foregroundColor(isBold ? .primary : .secondary)
            Spacer()
            Text(abs(value).formatted(localeManager.currencyFormatStyle))
                .font(isBold ? .body.bold() : .body)
                .foregroundColor(value < 0 ? .red : (isBold ? .green : .primary))
        }
    }
    
    @ViewBuilder
    private var customAttributesSection: some View {
        if !order.attributes.isEmpty {
            CustomCardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Custom Attributes")
                            .font(.headline.bold())
                    }
                    
                    ForEach(Array(order.attributes.keys.sorted()), id: \.self) { key in
                        if let value = order.attributes[key], !value.isEmpty {
                            HStack {
                                Text(key)
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(value)
                                    .font(.body)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var notesSection: some View {
        if let notes = order.additionalCostNotes, !notes.isEmpty {
            CustomCardView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.secondary)
                        Text("Notes")
                            .font(.headline.bold())
                    }
                    
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func formatCountdown(_ timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = (Int(timeInterval) % 86400) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m \(seconds)s"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
