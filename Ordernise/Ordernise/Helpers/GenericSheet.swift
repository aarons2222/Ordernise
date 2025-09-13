//
//  PermissionSheet.swift
//  PermissionTutorial
//
//  Created by Balaji Venkatesh on 21/07/25.
//
import SwiftUI



extension View {
    func GenericSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        title: String,
        showButton: Bool? = true,
        action: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(
            GenericSheetViewModifier(
                isPresented: isPresented,
                title: title,
                showButton: showButton,
                action: action,
                sheetContent: content
            )
        )
    }
}

fileprivate struct GenericSheetViewModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let showButton: Bool?
    let action: () -> Void
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            VStack(spacing: 20) {
                
                // Header
                HStack {
                    Text(title)
                        .font(.title)
                                     
                    Spacer()
                    
                    if let showButton = showButton, !showButton {
                        
                        Image(systemName: "multiply.circle")
                            .font(.title)
                            .foregroundStyle(Color.appTint.opacity(0.8))
                            .onTapGesture {
                                isPresented = false
                            }
                    }
                }

                // Content
                sheetContent()

                Spacer(minLength: 0)

                // Optional Dismiss Button
                if let showButton = showButton, showButton {
                    GlobalButton(title: "Dismiss", showIcon: false) {
                        isPresented = false
                        action()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .presentationDetents([.height(480)])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ContentView()
       
}
