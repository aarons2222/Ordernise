//
//  SupportView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 31/08/2025.
//

import SwiftUI

struct SupportView: View {
    
    @State private var showingSupport = false
     
    var body: some View {
        VStack {
            
            
            
            HeaderWithButton(
                title: String(localized: "Support", table: "Settings"),
                buttonContent: "line.3.horizontal.decrease.circle",
                isButtonImage: true,
                showTrailingButton: false,
                showLeadingButton: true,
                onButtonTap: {
                    
                    
                }
            )
            
            ScrollView{
                
                VStack(alignment: .leading){
             
                       

                    Button {
                        if let url = URL(string: "https://ordernise-facd9.web.app") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        
                        SettingsCardRow(title: "Terms and Conditions", subtitle:  "View our terms and conditions.")

                   
                    }
                    
                    
                    
                    
                    Button{
                        self.showingSupport = true
                    }label: {
                    
                        SettingsCardRow(title: "Support", subtitle:  "Get support here.")

            
                       
                    }
                    
                 
                    
                    
                }
            }
            .padding(.horizontal, 20)
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden)
        .fullScreenCover(isPresented: $showingSupport) {
            ContactSupportView()
        }
    
    }
}

#Preview {
    SupportView()
}
