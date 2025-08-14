//
//  CustomCardView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI



struct CustomCardView<Content: View>: View {
    let title: String?
    let content: Content
    let navigationLink: AnyView?
    
    init(_ title: String? = nil,
         navigationLink: AnyView? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.navigationLink = navigationLink
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
       
            
            content
                .padding()
                .frame(maxWidth: .infinity)
                .cardBackground()
            
        }
    
    }
}



struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}


//
//CustomCardView("Order Settings") {
//    
//    HStack{
//        
//        
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Order Status Options")
//                .font(.headline)
//                .foregroundColor(.text)
//            
//            
//            
//            Text("Select which statuses are available in your order workflow.")
//            
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.leading)
//            
//        }
//        
//        Spacer()
//    }
//    
//}
