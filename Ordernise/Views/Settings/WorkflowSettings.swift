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
                    
                    CustomCardView(String(localized: "Order Settings", table: "Settings")) {
                        
                        HStack(alignment: .center){
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "Order Status Options", table: "Settings"))
                                    .font(.headline)
                                    .foregroundColor(.text)
                                
                                
                                
                                Text(String(localized: "Select which statuses are available in your order workflow.", table: "Settings"))
                                
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            
                            Spacer()
                            
                            
                            Image(systemName: "chevron.right.circle")
                                .font(.title2)
                                .tint(Color.appTint)
                        }
                        
                    }
                }
                
                
                
                
                NavigationLink(destination: PlatformOptions()) {
                    
                    CustomCardView {
                        
                        HStack{
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "Platform Options", table: "Settings"))
                                    .font(.headline)
                                    .foregroundColor(.text)
                                
                                
                                
                                Text(String(localized: "Select which platforms are available in your order workflow.", table: "Settings"))
                                
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right.circle")
                                .font(.title2)
                                .tint(Color.appTint)
                            
                        }
                        
                    }.padding(.vertical, 3)
                }
                
                
                
                
                NavigationLink(destination: ShippingCompanyOptions()) {
                    
                    CustomCardView {
                        
                        HStack{
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "Shipping Companies"))
                                    .font(.headline)
                                    .foregroundColor(.text)
                                
                                
                                
                                Text(String(localized: "Select which shipping companies are available in your order workflow."))
                                
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right.circle")
                                .font(.title2)
                                .tint(Color.appTint)
                            
                        }
                        
                    }.padding(.vertical, 3)
                }
                
                
                NavigationLink(destination: CategoryOptions().enableSwipeBack()) {
                    CustomCardView{
                        
                        HStack{
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "Categories", table: "Settings"))
                                    .font(.headline)
                                    .foregroundColor(.text)
                                
                                Text(String(localized: "Organise your stock items by category to keep things easy to find.", table: "Settings"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right.circle")
                                .font(.title2)
                                .tint(Color.appTint)
                            
                        }
                    }
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
