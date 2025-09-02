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
                        CustomCardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Terms and Conditions")
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    Text("View our terms and conditions")
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
                    
                    
                    
                    
                    Button{
                        self.showingSupport = true
                    }label: {
                    
            
                        CustomCardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(localized: "Support", table: "Settings"))
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    Text(String(localized: "Get support here", table: "Settings"))
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
