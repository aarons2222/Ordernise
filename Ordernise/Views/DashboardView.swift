//
//  DashboardView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI

struct DashboardView: View {
    
    @State var showSettings = false

    
    
    var body: some View {
        
        VStack{
            
            
            HeaderWithButton(
                title: "Dashboard",
                buttonImage: "line.3.horizontal.decrease.circle",
                showButton: true
            ) {
                print("aaaa")
            }
            
            
            
            Spacer()
        }

     
      
    }
}

#Preview {
    DashboardView()
}




import SwiftUI

struct HeaderWithButton: View {
    let title: String
    let buttonImage: String
    let showButton: Bool
    let onButtonTap: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.largeTitle)
                .padding(.horizontal, 15)

            Spacer()

            if showButton {
                Button(action: onButtonTap) {
                    Image(systemName: buttonImage)
                        .font(.title)
                       
                        .padding(.horizontal)
                }
            }
        }
        .frame(height: 50)
        
    }
}
