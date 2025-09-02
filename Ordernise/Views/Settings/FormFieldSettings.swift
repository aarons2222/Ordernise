//
//  FormFieldSettings.swift
//  Ordernise
//
//  Created by Aaron Strickland on 31/08/2025.
//

import SwiftUI

struct FormFieldSettings: View {
    var body: some View {
        VStack {
            
            
            
            HeaderWithButton(
                title: String(localized: "Form Fields", table: "Settings"),
                buttonContent: "line.3.horizontal.decrease.circle",
                isButtonImage: true,
                showTrailingButton: false,
                showLeadingButton: true,
                onButtonTap: {
                    
                    
                }
            )
            
            ScrollView{
                
                VStack(alignment: .leading){
                 
                    
                    
          

                    
                    
                    NavigationLink(destination: OrderFieldSettings()) {
                        CustomCardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(localized: "Order Fields", table: "Settings"))
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    Text(String(localized: "Customise which fields are shown when creating and editing orders", table: "Settings"))
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
                        .padding(.bottom, 3)
                    }
                
                    
                    
                    
                    
                    NavigationLink(destination: StockFieldSettings()) {
                        CustomCardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(localized: "Stock Fields", table: "Settings"))
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    Text(String(localized: "Customise which fields are shown when creating and editing stock items.", table: "Settings"))
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
                
                
                
                
            }
            .padding(.horizontal, 20)
            .scrollIndicators(.hidden)
            .toolbar(.hidden)
            
            
            Spacer()
        }
    }
}

#Preview {
    FormFieldSettings()
}
