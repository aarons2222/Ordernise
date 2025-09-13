////
////  ToastManager.swift
////  Ordernise
////
////  Created by Aaron Strickland on 03/09/2025.
////
//
//import SwiftUI
//internal import Combine
//
//
//class ToastManager: ObservableObject {
//    static let shared = ToastManager()
//    
//    @Published var isPresented: Bool = false
//    @Published var title: String = ""
//    @Published var message: String = ""
//    @Published var type: ToastType = .info
//    @Published var isInSheet: Bool = false
//    @Published var pin: String = ""
//    
//    private init() {}
//    
//    func showToast(type: ToastType = .info, title: String, message: String, isInSheet: Bool = false, pin: String = "") {
//        
//        self.type = type
//        self.title = title
//        self.message = message
//        self.isInSheet = isInSheet
//        self.pin = pin
//        
//        withAnimation {
//            self.isPresented = true
//        }
//        
//        // Auto-dismiss after 3 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            withAnimation {
//                self.isPresented = false
//            }
//        }
//    }
//}
//
//struct ToastModifier: ViewModifier {
//    @ObservedObject var toastManager = ToastManager.shared
//    @GestureState private var dragOffset: CGSize = .zero
//    @State private var draggedOffset: CGFloat = 0
//    let isInSheet: Bool
//    
//    init(isInSheet: Bool = false) {
//        self.isInSheet = isInSheet
//    }
//    
//    func body(content: Content) -> some View {
//        ZStack(alignment: .top) {
//            content
//            
//            if toastManager.isPresented {
//                ToastView(isInSheet: isInSheet)
//                    .transition(.asymmetric(
//                        insertion: .move(edge: .top).combined(with: .opacity),
//                        removal: .move(edge: .top).combined(with: .opacity)
//                    ))
//                    .zIndex(1)
//            }
//        }
//        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.isPresented)
//    }
//}
//
//private struct ToastView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @ObservedObject var toastManager = ToastManager.shared
//    let isInSheet: Bool
//    
//    init(isInSheet: Bool = false) {
//        self.isInSheet = isInSheet
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                HStack(alignment: .center, spacing: 12) {
//                    // Show initials for message type, icon for other types
//            
//                        // Standard icon for non-message types
//                        Image(systemName: toastManager.type.symbol)
//                            .font(.title)
//                            .foregroundColor(toastManager.type.color)
//                    
//                    
//                    VStack(alignment: .leading){
//                        Text(toastManager.title)
//                            .font(.subheadline)
//                            .fontWeight(.bold)
//                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6))
//                            .multilineTextAlignment(.leading)
//                            .fixedSize(horizontal: false, vertical: true)
//                        
//                        Text(toastManager.message)
//                            .font(.body)
//                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6))
//                            .multilineTextAlignment(.leading)
//                            .fixedSize(horizontal: false, vertical: true)
//                    }
//                    Spacer(minLength: 10)
//                    
//                  
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 12)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(colorScheme == .dark ? Color.black.opacity(0.8) : .white)
//                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(
//                            // Use PIN-based coloring for message toasts, default coloring for other types
//                            toastManager.type == .message && !toastManager.pin.isEmpty ?
//                                Color("Color\(String(toastManager.pin.prefix(1)))") : toastManager.type.color,
//                            lineWidth: 2.5
//                        )
//                )
//                .padding(.horizontal)
//               
//          
//            }
//            // Position toast higher in the view, with adjustment for sheets
//            .padding(.top, 10)
//        }
//    }
//}
//
//extension View {
//    func toastView(isInSheet: Bool = false) -> some View {
//        self.modifier(ToastModifier(isInSheet: isInSheet))
//    }
//}
//
//
//
//#Preview {
//    ZStack {
//        Color.gray.opacity(0.2).ignoresSafeArea()
//        VStack(spacing: 20) {
//            Button("Show Success Toast") {
//                ToastManager.shared.showToast(
//                    type: .warning, title: "Success",
//                    message: "Operation completed successfully"
//                )
//            }
//            
//            Button("Show Error Toast") {
//                ToastManager.shared.showToast(
//                    type: .error, title: "Error",
//                    message: "Something went wrong"
//                )
//            }
//            
//         
//        }
//    }
//    .toastView()
//}
//
//
//
//
//
//public enum ToastType: Equatable {
//    case success
//    case error
//    case warning
//    case info
//    case message
//    case custom(symbol: String, color: Color)
//    
//    var symbol: String {
//        switch self {
//        case .success: return "checkmark.circle"
//        case .error: return "xmark.circle"
//        case .warning: return "exclamationmark.circle"
//        case .info: return "info.circle"
//        case .message: return "message.badge.circle.rtl"
//        case .custom(let symbol, _): return symbol
//        }
//    }
//    
//    var color: Color {
//        switch self {
//        case .success: return .green
//        case .error: return .red
//        case .warning: return .orange
//        case .info: return .blue
//        case .message: return .blue
//        case .custom(_, let color): return color
//        }
//    }
//    
//    // Custom Equatable implementation to handle the custom case
//    public static func == (lhs: ToastType, rhs: ToastType) -> Bool {
//        switch (lhs, rhs) {
//        case (.success, .success), (.error, .error), (.warning, .warning), (.info, .info), (.message, .message):
//            return true
//        case (.custom(let lhsSymbol, let lhsColor), .custom(let rhsSymbol, let rhsColor)):
//            return lhsSymbol == rhsSymbol && lhsColor == rhsColor
//        default:
//            return false
//        }
//    }
//}
//


//
//  ToastManager.swift
//  Ordernise
//
//  Created by Aaron Strickland on 03/09/2025.
//

import SwiftUI
internal import Combine


class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var isPresented: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var type: ToastType = .info
    @Published var isInSheet: Bool = false
    @Published var pin: String = ""
    
    private init() {}
    
    func showToast(type: ToastType = .info, title: String, message: String, isInSheet: Bool = false, pin: String = "") {
        
        self.type = type
        self.title = title
        self.message = message
        self.isInSheet = isInSheet
        self.pin = pin
        
        withAnimation {
            self.isPresented = true
        }
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.isPresented = false
            }
        }
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared
    @GestureState private var dragOffset: CGSize = .zero
    @State private var draggedOffset: CGFloat = 0
    let isInSheet: Bool
    
    init(isInSheet: Bool = false) {
        self.isInSheet = isInSheet
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if toastManager.isPresented {
                ToastView(isInSheet: isInSheet)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.isPresented)
    }
}

private struct ToastView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var toastManager = ToastManager.shared
    let isInSheet: Bool
    
    init(isInSheet: Bool = false) {
        self.isInSheet = isInSheet
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(alignment: .center, spacing: 12) {
                    // Show initials for message type, icon for other types
            
                        // Standard icon for non-message types
                        Image(systemName: toastManager.type.symbol)
                            .font(.largeTitle)
                            .foregroundColor(toastManager.type.color)
                    
                    
                    VStack(alignment: .leading){
                        Text(toastManager.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(toastManager.message)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 10)
                    
                  
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                   Capsule()
                    .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            // Use PIN-based coloring for message toasts, default coloring for other types
                            toastManager.type == .message && !toastManager.pin.isEmpty ?
                                Color("Color\(String(toastManager.pin.prefix(1)))") : toastManager.type.color,
                            lineWidth: 2.5
                        )
                )
                .padding(.horizontal)
               
          
            }
            // Position toast higher in the view, with adjustment for sheets
            .padding(.top, 10)
        }
    }
}

extension View {
    func toastView(isInSheet: Bool = false) -> some View {
        self.modifier(ToastModifier(isInSheet: isInSheet))
    }
}



#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        VStack(spacing: 20) {
            Button("Show Success Toast") {
                ToastManager.shared.showToast(
                    type: .success, title: "Success",
                    message: "Operation completed successfully"
                )
            }
            
            Button("Show Error Toast") {
                ToastManager.shared.showToast(
                    type: .error, title: "Error",
                    message: "Something went wrong"
                )
            }
            
         
        }
    }
    .toastView()
}





public enum ToastType: Equatable {
    case success
    case error
    case warning
    case info
    case message
    case custom(symbol: String, color: Color)
    
    var symbol: String {
        switch self {
        case .success: return "checkmark.circle"
        case .error: return "xmark.circle"
        case .warning: return "exclamationmark.circle"
        case .info: return "info.circle"
        case .message: return "message.badge.circle.rtl"
        case .custom(let symbol, _): return symbol
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        case .message: return .blue
        case .custom(_, let color): return color
        }
    }
    
    // Custom Equatable implementation to handle the custom case
    public static func == (lhs: ToastType, rhs: ToastType) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success), (.error, .error), (.warning, .warning), (.info, .info), (.message, .message):
            return true
        case (.custom(let lhsSymbol, let lhsColor), .custom(let rhsSymbol, let rhsColor)):
            return lhsSymbol == rhsSymbol && lhsColor == rhsColor
        default:
            return false
        }
    }
}

