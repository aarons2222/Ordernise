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
    @State private var isEditing: Bool = false
    
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
                    .onTapGesture {
                        isEditing = true
                    }
                    .onChange(of: textValue) {
                        isEditing = true
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
        .onChange(of: value?.wrappedValue) { _, newValue in
            // Only update the text field if the user is not currently editing
            if !isEditing {
                let displayValue = newValue ?? 0
                textValue = displayValue == 0 ? "" : formattedValue(displayValue)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
            // When user finishes editing, stop editing mode but DON'T reformat
            // The binding should already have the correct value from onChange
            isEditing = false
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
            print("🔢 [CustomNumberField] Updating binding from '\(string)' to \(doubleValue)")
            binding.wrappedValue = doubleValue
        } else if filtered.isEmpty {
            print("🔢 [CustomNumberField] Setting binding to 0 (empty field)")
            binding.wrappedValue = 0
        } else {
            print("🔢 [CustomNumberField] Could not parse '\(string)' as Double")
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
