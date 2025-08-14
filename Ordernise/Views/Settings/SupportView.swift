//
//  SupportView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 13/08/2025.
//

//
//  SupportView.swift
//  Powerful Reports
//
//  Created by Aaron Strickland on 20/01/2025.
//

import SwiftUI
import MessageUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIssue: IssueType = .requestFeature
    @State private var description = ""
    @State private var showMailError = false
    @FocusState private var focusedField: Bool?
    
    enum IssueType {
        case none
        
        case requestFeature
        case otherIssues
    }
    
    var body: some View {

        
            VStack(alignment: .leading, spacing: 0) {
       
                
                HeaderWithButton(
                    title: String(localized: "Support"),
                    buttonContent: "line.3.horizontal.decrease.circle",
                    isButtonImage: false,
                    showTrailingButton: false,
                    showLeadingButton: true,
                    onButtonTap: {
                  
                        
                    }
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("What can we help you with?")
                            .font(.title2)
                            .foregroundStyle(.color1)
                            .padding(.vertical, 40)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            issueButton(.requestFeature, "Request New Feature")
                            issueButton(.otherIssues, "Report a issue")
                        }
                        
                        // Conditional Input Fields
                        if selectedIssue != .none {
                            VStack(spacing: 20) {
                             
                                
                            
                                
                                if selectedIssue == .requestFeature {
                                    CustomTextEditor(text: $description,
                                                  placeholder: "Please describe the feature you'd like to see...",
                                                  systemImage: "text.alignleft",
                                                  isFocused: $focusedField)
                                }
                                
                                if selectedIssue == .otherIssues {
                                    CustomTextEditor(text: $description,
                                                  placeholder: "Please describe your issue...",
                                                  systemImage: "text.alignleft",
                                                  isFocused: $focusedField)
                                }
                            }
                            .padding(.top, 24)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80) // Add padding for the button
                }
                
                Spacer()
                GlobalButton(title: "Send Email") {
                    sendEmail()
                }
                .padding(.horizontal)
                .padding(.bottom)
                
            }
            
    
         
    
        .navigationBarHidden(true)

        .alert("Email Error", isPresented: $showMailError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your device is not configured to send emails. Please check your email settings and try again.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button {
                        self.focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.color2)
                            .padding(.trailing, 10)
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .frame(height: 45)
                .background {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
        }
    }
    
    private func issueButton(_ type: IssueType, _ title: String) -> some View {
        Button {
            withAnimation {
                selectedIssue = type
            }
        } label: {
            HStack {
                RadialButton(color: .color1,
                           isSelected: selectedIssue == type,
                           size: 35)
                
                Text(title)
                    .foregroundStyle(selectedIssue == type ? .color1 : .gray)
                    .font(.callout)
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    private func sendEmail() {
        var emailBody = ""
        
        switch selectedIssue {
      
        case .requestFeature:
            emailBody = "Feature Request Description: \(description)"
        case .otherIssues:
            emailBody = "Issue Description: \(description)"
        case .none:
            return
        }
        
        if let url = createEmailUrl(body: emailBody) {
            UIApplication.shared.open(url)
            // Clear the form data
            withAnimation {
               
                description = ""
                selectedIssue = .otherIssues
            }
        } else {
            showMailError = true
        }
    }
    
    private func createEmailUrl(body: String) -> URL? {
        let to = "support@ordernise.co.uk"
        let subject = "Support Request: \(selectedIssue)"
        
        
        let urlString = "mailto:\(to)?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        return URL(string: urlString ?? "")
    }
}


struct RadialButton: View {
    var color: Color
    var isSelected: Bool
    var size: CGFloat
    
    private var innerCircleSize: CGFloat { size * 0.75 }
    private var strokeWidth: CGFloat { size * 0.1 }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: isSelected ? strokeWidth : 0)
                .frame(width: size, height: size)
            Circle()
                .foregroundStyle(.color1.opacity(0.3))
                .frame(width: innerCircleSize, height: innerCircleSize)
            
            if(isSelected){
                Image(systemName: "checkmark")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
        }
    }
}

#Preview {
    SupportView()
}



