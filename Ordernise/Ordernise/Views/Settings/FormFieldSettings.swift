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
                        
                        SettingsCardRow(title: "Order Fields", subtitle:  "Customise which fields are shown when creating and editing orders.")
                  
                        .padding(.bottom, 3)
                    }
                
                    
                    
                    
                    
                    NavigationLink(destination: StockFieldSettings()) {
                        
                        SettingsCardRow(title: "Stock Fields", subtitle:  "Customise which fields are shown when creating and editing stock items.")
                        
        
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
