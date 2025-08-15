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
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.body)
                .fontWeight(.regular)
                .foregroundColor(.text)
            
        }
        .padding(.leading, sectionHeaderLeadingPadding)
    }
    
}

#Preview {
    SectionHeader(title: "aaaa")
}
