//
//  MyDatePicker.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//


import SwiftUI

struct MyDatePicker: View {
    @Binding var selectedDate: Date

    var body: some View {
        
        // Put your own design here
        VStack {
            Text(selectedDate.formatted(.dateTime.day().month().year()))
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.clear)
        .foregroundColor(Color.appTint)
        .cornerRadius(30)
        .overlay( // Use overlay for rounded border
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.appTint.opacity(0.8), lineWidth: 2)
        )

        // Put the actual DataPicker here with overlay
        .overlay {
            DatePicker(
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date) {
                    
                }
                .labelsHidden()
                .colorMultiply(.clear)
                .tint(Color.appTint)
        }

    }
}


