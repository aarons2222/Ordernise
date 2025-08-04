//
//  CustomTextField.swift
//  Ordernise
//
//  Created by Aaron Strickland on 02/08/2025.
//
import SwiftUI

struct CustomTextField: View {
    let text: Binding<String>
    let placeholder: String
    let systemImage: String
    var isSecure: Bool = false
    var showSecureToggle: Bool = false
    var onToggleSecure: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(Color.appTint)

            if isSecure {
                SecureField(placeholder, text: text)
                    .textContentType(.none)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: text)
                    .textContentType(.none)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            if showSecureToggle {
                Button(action: {
                    onToggleSecure?()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 13)
        .background(
           Capsule()
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.appTint, lineWidth: 2)
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
