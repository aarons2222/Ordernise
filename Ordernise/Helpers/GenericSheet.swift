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
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(
            GenericSheetViewModifier(
                isPresented: isPresented,
                title: title,
                action: action,
                sheetContent: content
            )
        )
    }
}

fileprivate struct GenericSheetViewModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let action: () -> Void
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                VStack{
                    HStack{
                        Text(title)
                            .font(.title)
                        
                        Spacer()
                    }
                    
               
                        
                        sheetContent()
                        .padding(.top, 20)
                        
                        Spacer(minLength: 0)
                    
                    
                    
                    
                    
                    GlobalButton(title:"Dismiss", showIcon: false,  action: {
                    
                        
                        
                        isPresented = false
                        action()
                    })
           

                    
                    
                    
                        
                      
                    }
                
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .presentationDetents([.height(480)])
                .interactiveDismissDisabled()
            }
    }
}


#Preview {
    ContentView()
       
}
