//
//  ListSection.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//


import SwiftUI

struct ListSection<Content: View>: View {
    var title: String
    var isRequired: Bool? = false
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack{
                SectionHeader(title: title, isRequired: isRequired)
                    .padding(.vertical, 5)
                    .padding(.leading, 0)
                Spacer()
            }
            content()
        }
    }
}




