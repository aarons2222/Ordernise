//
//  Workflow.swift
//  Ordernise
//
//  Created by Aaron Strickland on 31/08/2025.
//

import SwiftUI

struct WorkflowSettings: View {
    var body: some View {
        VStack {
            
            
            
            HeaderWithButton(
                title: String(localized: "Workflow", table: "Settings"),
                buttonContent: "line.3.horizontal.decrease.circle",
                isButtonImage: true,
                showTrailingButton: false,
                showLeadingButton: true,
                onButtonTap: {
                    
                    
                }
            )
            
            ScrollView{
            
            VStack(alignment: .leading){
                
                
                
                
           
                
                
                
                NavigationLink(destination: OrderStatusOptions()) {
                    
                    
                    
                    SettingsCardRow(title: "Order Status Options", subtitle:  "Select which statuses are available in your order workflow.")

                }
                
                
                
                
                NavigationLink(destination: PlatformOptions()) {
                    
                    
                    SettingsCardRow(title: "Platform Options", subtitle:  "Select which platforms are available in your order workflow.")
                        .padding(.vertical, 3)

                }
                
                
                
                
                NavigationLink(destination: ShippingCompanyOptions()) {
                    
                    
                    SettingsCardRow(title: "Shipping Companies", subtitle:  "Select which shipping companies are available in your order workflow.")
                        .padding(.vertical, 3)
                    

                }
                
                
                NavigationLink(destination: CategoryOptions().enableSwipeBack()) {
                    
                    SettingsCardRow(title: "Categories", subtitle:  "Organise your stock items by category to keep things easy to find.")
                        .padding(.vertical, 3)

                }
                
            }
            .padding(.top, 15)
            
            }.scrollIndicators(.hidden)
            .padding(.horizontal, 20)
            
            
            
            
            
            
            Spacer()
        }
        
        .toolbar(.hidden)
    }
}

#Preview {
    WorkflowSettings()
}
