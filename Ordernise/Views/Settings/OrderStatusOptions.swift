//
//  Order Status Options.swift
//  Ordernise
//
//  Created by Aaron Strickland on 29/07/2025.
//

import SwiftUI

struct OrderStatusOptions: View {
    
    
    // Order Status Settings - Default to all enabled
    @AppStorage("enabledOrderStatuses") private var enabledOrderStatusesData: Data = {
        let defaultStatuses = OrderStatus.allCases.map { $0.rawValue }
        return (try? JSONEncoder().encode(defaultStatuses)) ?? Data()
    }()
    
    
    var enabledOrderStatuses: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: enabledOrderStatusesData)) ?? OrderStatus.allCases.map { $0.rawValue }
        }
        set {
            enabledOrderStatusesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func isStatusEnabled(_ status: OrderStatus) -> Bool {
        enabledOrderStatuses.contains(status.rawValue)
    }
    
    func toggleStatus(_ status: OrderStatus) {
        var currentStatuses = enabledOrderStatuses
        if currentStatuses.contains(status.rawValue) {
            // Don't allow disabling all statuses - must have at least one
            if currentStatuses.count > 1 {
                currentStatuses.removeAll { $0 == status.rawValue }
            }
        } else {
            currentStatuses.append(status.rawValue)
        }
        enabledOrderStatusesData = (try? JSONEncoder().encode(currentStatuses)) ?? Data()
    }
    
    
    
    
    
    
    
    
    var body: some View {
        
        VStack{
          
            
            HeaderWithButton(
                title: String(localized: "Order status option"),
                buttonContent: "plus.circle",
                isButtonImage: false,
                showTrailingButton: false,
                showLeadingButton: true,
                onButtonTap: {
               
                    
                }
            )
      
            ScrollView{
                
              
                
                VStack{
                    
                    HStack{
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "Choose which order statuses are available in your workflow"))
                                .font(.headline)
                             
                            Text(String(localized: "At least one status must remain enabled"))
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 4)
                        
                        
                        Spacer()
                    }
                    
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        VStack(spacing: 0) {
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { isStatusEnabled(status) },
                                    set: { _ in toggleStatus(status) }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(status.localizedTitle)
                                            .font(.headline)
                                        Text(statusDescription(for: status))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                               
                                .tint(Color.appTint)
                                .disabled(enabledOrderStatuses.count == 1 && isStatusEnabled(status))
                                .padding(.horizontal, 0)
                                .padding(.vertical)
                            }
                            
                            // Show divider only if not the last item
                            if status != OrderStatus.allCases.last {
                                Divider()
                            }
                        }
                    }

                    
                    
                }
                .padding()
                .cardBackground()
                
                
               
                
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 60)
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
     
       
    
    }

    private func statusDescription(for status: OrderStatus) -> String {
        switch status {
        case .received: return String(localized: "Order has been recorded")
        case .pending: return String(localized: "Waiting for payment or confirmation")
        case .processing: return String(localized: "Being prepared/packed")
        case .shipped: return String(localized: "Handed over to carrier")
        case .delivered: return String(localized: "Reached customer")
        case .fulfilled: return String(localized: "Successfully completed")
        case .returned: return String(localized: "Sent back by customer")
        case .refunded: return String(localized: "Payment returned to customer")
        case .canceled: return String(localized: "Manually or automatically canceled")
        case .failed: return String(localized: "Payment or processing failure")
        case .onHold: return String(localized: "Temporarily paused")
        }
    }

}

#Preview {
    OrderStatusOptions()
}
