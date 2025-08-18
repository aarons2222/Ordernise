//
//  MyDatePicker.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//


import SwiftUI

struct MyDatePicker: View {
    @Binding var selectedDate: Date
    var showFutureDate: Bool = false
    
    private var dateRange: PartialRangeThrough<Date> {
        if showFutureDate {
            // Allow up to 10 years in the future
            let maxDate = Calendar.current.date(byAdding: .year, value: 10, to: Date()) ?? Date()
            return ...maxDate
        } else {
            // Only allow up to today
            return ...Date()
        }
    }

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
                selection: Binding(
                    get: { selectedDate },
                    set: { selectedDate = $0 }
                ),
                in: dateRange,
                displayedComponents: .date) {
                    
                }
                .labelsHidden()
                .colorMultiply(.clear)
                .tint(Color.appTint)
        }

    }
}


