//
//  GlobalButton.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import SwiftUI

struct GlobalButton: View {
    // Properties
    var title: String
    var backgroundColor: Color = Color.appTint
    var foregroundColor: Color = .white
    var verticalPadding: CGFloat = 14
    var horizontalPadding: CGFloat = 5
    var showIcon: Bool?
    var icon: String?
    var action: () -> Void


    
    

    // Body
    var body: some View {
        Button(action: {
            action()
        }) {
            
            HStack{
                if (showIcon ?? false){
                    
                    Image(systemName: icon ?? "chevron.right")
                        
                }
                
                
                Text(title)
                
            }
                
            .foregroundColor(foregroundColor)
            .font(.headline)
            .fontWeight(.semibold)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)
            .background(backgroundColor.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .frame(height: 50)
        .padding(horizontalPadding)
    
    }
}

#Preview {
    GlobalButton(title: "Press Me", action: {
           print("Button pressed!")
       })
}


