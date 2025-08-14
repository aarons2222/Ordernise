//
//  CustomTextEditor.swift
//  Ordernise
//
//  Created by Aaron Strickland on 02/08/2025.
//


import SwiftUI

struct CustomTextEditor: View {
    let text: Binding<String>
    let placeholder: String
    let systemImage: String
    let isFocused: FocusState<Bool?>.Binding
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: text)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .padding(.leading, 35)
                .focused(isFocused, equals: true)
                .autocapitalization(.sentences)
                .disableAutocorrection(true)
            
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.appTint)
                    .font(.title2)
                
                Spacer()
            }
            .allowsHitTesting(false)
            .padding(.top, 8)
            .padding(.leading, 12)
            
            if text.wrappedValue.isEmpty {
                HStack(spacing: 12) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .font(.body)
                        .padding(.leading, 35)
                    
                    Spacer()
                }
                .allowsHitTesting(false)
                .padding(.top, 8)
                .padding(.leading, 12)
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.appTint, lineWidth: 2)
        )
    }
}
