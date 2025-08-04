//
//  ListSection.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//


import SwiftUI

struct ListSection<Content: View>: View {
    var title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            content()
        }
    }
}




