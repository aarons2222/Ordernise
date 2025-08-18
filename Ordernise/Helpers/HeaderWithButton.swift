//
//  HeaderWithButton.swift
//  Ordernise
//
//  Created by Aaron Strickland on 12/08/2025.
//


// MARK: - HeaderWithButton Component

import SwiftUI

struct HeaderWithButton: View {
    let title: String
    let buttonContent: String
    let isButtonImage: Bool
    let showTrailingButton: Bool
    let showLeadingButton: Bool
    let isButtonDisabled: Bool
    let onButtonTap: (() -> Void)?
    let onLeadingButtonTap: (() -> Void)?
    
    init(title: String, buttonContent: String, isButtonImage: Bool = false, showTrailingButton: Bool = true, showLeadingButton: Bool = true, isButtonDisabled: Bool = false, onButtonTap: (() -> Void)? = nil, onLeadingButtonTap: (() -> Void)? = nil) {
        self.title = title
        self.buttonContent = buttonContent
        self.isButtonImage = isButtonImage
        self.showTrailingButton = showTrailingButton
        self.showLeadingButton = showLeadingButton
        self.isButtonDisabled = isButtonDisabled
        self.onButtonTap = onButtonTap
        self.onLeadingButtonTap = onLeadingButtonTap
    }
    
    
    
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        HStack(alignment: .center) {
            if showLeadingButton {
                Button(action: {
                    if let onLeadingButtonTap = onLeadingButtonTap {
                        onLeadingButtonTap()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "chevron.backward.circle")
                        .font(.title)
                        .foregroundColor(.appTint)
                        .padding(.leading)
                }
            }
            
            Text(title)
                .font(.title)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .truncationMode(.tail)
                .padding(.horizontal, showLeadingButton ? 5 : 15)
            
            Spacer()
            
            if showTrailingButton {
                Button(action: {
                    onButtonTap?()
                }) {
                    if isButtonImage {
                        Image(systemName: buttonContent)
                            .font(.title)
                            .foregroundColor(isButtonDisabled ? .gray : .appTint)
                    } else {
                        Text(buttonContent)
                            .font(.title3)
                            .foregroundColor(isButtonDisabled ? .gray : .appTint)
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(height: 50)

    }
}
