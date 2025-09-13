//
//  CustomHeaderView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//


import SwiftUI

struct CustomHeaderVIew: View {
    @Environment(\.presentationMode) var presentationMode
    

    
      var title: String
      var showFilterButton: Bool?
      @Binding var showFilters: Bool
      
      init(title: String, showFilterButton: Bool? = nil, showFilters: Binding<Bool> = .constant(false)) {
          self.title = title
          self.showFilterButton = showFilterButton
          self._showFilters = showFilters
      }
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.appTint)
                .frame(height: 150)
                .overlay(alignment: .leading) {
                    Circle()
                        .fill(Color.appTint)
                        .overlay {
                            Circle()
                                .fill(.white.opacity(0.2))
                        }
                        .scaleEffect(2, anchor: .topLeading)
                        .offset(x: -50, y: -40)
                }
                .clipShape(Rectangle())
            
            VStack {
                Spacer()
                
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward.circle")
                            .font(.title)
                            .fontWeight(.regular)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Text(title)
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    if let showFilterButton = showFilterButton, showFilterButton {
                        Button {
                            showFilters.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title)
                                .fontWeight(.regular)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
            }
            .padding()
            .frame(height: 150)
        }
        .ignoresSafeArea(.container, edges: .all)
   
    }
}
