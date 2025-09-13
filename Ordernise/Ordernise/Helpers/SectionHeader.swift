//
//  SectionHeader.swift
//  Ordernise
//
//  Created by Aaron Strickland on 13/08/2025.
//

import SwiftUI


struct SectionHeader: View {
    
    @State private var sectionHeaderLeadingPadding: CGFloat = 12
  
    
    let title: String
    var isRequired: Bool? = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack{
                Text(title)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(.text)
             
                if isRequired == true {
                    
                    Text("*")
                        .font(.title3)
                        .fontWeight(.regular)
                        .foregroundColor(.appTint)
                        .padding(.bottom, 5)
                        .padding(.leading, -5)
                    
                }
            }
            
            
        }
        .padding(.leading, sectionHeaderLeadingPadding)
    }
    
}

#Preview {
    SectionHeader(title: "aaaa")
}
