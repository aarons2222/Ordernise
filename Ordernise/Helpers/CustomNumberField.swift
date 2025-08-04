//
//  CustomNumberField.swift
//  Ordernise
//
//  Created by Aaron Strickland on 02/08/2025.
//

import SwiftUI
struct CustomNumberField: View {
    let value: Binding<Double>? // Optional Binding for editable or read-only
    let placeholder: String
    let systemImage: String
    let format: FloatingPointFormatStyle<Double>.Currency?

    @State private var textValue: String = ""
    
    // Initializer without format (backward compatibility)
    init(value: Binding<Double>?, placeholder: String, systemImage: String) {
        self.value = value
        self.placeholder = placeholder
        self.systemImage = systemImage
        self.format = nil
    }
    
    // Initializer with format
    init(value: Binding<Double>?, placeholder: String, systemImage: String, format: FloatingPointFormatStyle<Double>.Currency) {
        self.value = value
        self.placeholder = placeholder
        self.systemImage = systemImage
        self.format = format
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.appTint)

            if let binding = value {
                TextField(placeholder, text: $textValue)
                    .keyboardType(.decimalPad)
                    .textContentType(.none)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: textValue) {
                        updateValue(from: textValue, binding: binding)
                    }
            } else {
                Text(textValue)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 13)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.appTint, lineWidth: 2)
        )
        .onAppear {
            let displayValue = value?.wrappedValue ?? 0
            textValue = displayValue == 0 ? "" : formattedValue(displayValue)
        }
        .onChange(of: value?.wrappedValue) { newValue in
            let displayValue = newValue ?? 0
            textValue = displayValue == 0 ? "" : formattedValue(displayValue)
        }
    }

    private func updateValue(from string: String, binding: Binding<Double>) {
        let filtered = string.filter { "0123456789.".contains($0) }
        if filtered != string {
            textValue = filtered
            return
        }

        let dots = filtered.filter { $0 == "." }
        if dots.count > 1 {
            let firstDotIndex = filtered.firstIndex(of: ".")!
            textValue = String(filtered.prefix(upTo: filtered.index(after: firstDotIndex))) +
                filtered.suffix(from: filtered.index(after: firstDotIndex)).replacingOccurrences(of: ".", with: "")
            return
        }

        if let doubleValue = Double(filtered) {
            binding.wrappedValue = doubleValue
        } else if filtered.isEmpty {
            binding.wrappedValue = 0
        }
    }

    private func formattedValue(_ value: Double) -> String {
        if let format = format {
            return value.formatted(format)
        } else {
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f", value)
            } else {
                return String(value)
            }
        }
    }
}
