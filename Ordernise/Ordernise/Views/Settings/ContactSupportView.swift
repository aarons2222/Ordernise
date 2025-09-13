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
import UIKit

struct ContactSupportView: View {
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
          
                
            }
            
    
         
    
            .toolbar(.hidden)

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
            emailBody = "Ordernise Feature Request: \(description)"
        case .otherIssues:
            emailBody = "Ordernise Issue: \(description)"
        case .none:
            return
        }
        
        
        if description.isEmpty{
            emailBody = ""
            emailBody += "\n\n" + getDebugInfo()
        }else{
            emailBody += "\n\n" + getDebugInfo()
        }
        // Append debug information
     
        
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
    
    private func getDebugInfo() -> String {
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let systemVersion = device.systemVersion
        let deviceModel = device.model
        let deviceName = device.name
        let systemName = device.systemName
        let locale = Locale.current.identifier
        
        let debugInfo = """
        
        ------- DEBUG INFORMATION -------
        App Version: \(appVersion) (\(buildNumber))
        Device: \(deviceName)
        Model: \(deviceModel)
        Operating System: \(systemName) \(systemVersion)
        Locale: \(locale)
        Timestamp: \(Date().formatted())
        ---------------------------------
        """
        
        return debugInfo
    }
    
    private func createEmailUrl(body: String) -> URL? {
        let to = "support@ordernise.co.uk"
        let subject = "Ordernise Support Request"
        
        
      
        
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
           
            
      
                Image(systemName: isSelected ? "checkmark.circle" : "circle")
                    .font(.title)
                
                    .foregroundStyle(color)
          
        }
    }
}

#Preview {
    ContactSupportView()
}



