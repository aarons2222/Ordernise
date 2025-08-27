//
//  Paywall.swift
//  Ordernise
//
//  Created by Aaron Strickland on 26/08/2025.
//


import SwiftUI
import StoreKit

/// IAP View Images
enum IAPImage: String, CaseIterable {
    /// Raw value represents the asset image
    case one = "IAP1"
    case two = "IAP2"
    case three = "IAP3"
    case four = "IAP4"
}

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var loadingStatus: (Bool, Bool) = (false, false)
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let isSmalleriPhone = size.height < 700
            
            VStack(spacing: 0) {
                Group {
                    if isSmalleriPhone {
                        SubscriptionStoreView(productIDs: Self.productIDs, marketingContent: {
                            CustomMarketingView()
                        })
                        .subscriptionStoreControlStyle(.compactPicker, placement: .bottomBar)
                    } else {
                        SubscriptionStoreView(productIDs: Self.productIDs, marketingContent: {
                            CustomMarketingView()
                        })
                        .subscriptionStoreControlStyle(.pagedProminentPicker, placement: .bottomBar)
                    }
                }
                .tint(Color.appTint)
                .subscriptionStorePickerItemBackground(.ultraThinMaterial)
                .storeButton(.visible, for: .restorePurchases)
                .storeButton(.hidden, for: .policies)
                .onInAppPurchaseStart { product in
                    subscriptionManager.isLoading = true
                    print("Purchasing \(product.displayName)")
                }
                .onInAppPurchaseCompletion { product, result in
                    Task {
                        await subscriptionManager.checkSubscriptionStatus()
                        
                        switch result {
                        case .success(let result):
                            switch result {
                            case .success(_):
                                print("Purchase successful")
                                // Check if user is now subscribed and dismiss if so
                                if subscriptionManager.isSubscribed {
                                    dismiss()
                                }
                            case .pending:
                                print("Purchase pending")
                            case .userCancelled:
                                print("Purchase cancelled")
                            @unknown default:
                                break
                            }
                        case .failure(let error):
                            subscriptionManager.errorMessage = error.localizedDescription
                            print("Purchase error: \(error.localizedDescription)")
                        }
                        
                        subscriptionManager.isLoading = false
                    }
                }
                .subscriptionStatusTask(for: "21764785") { taskResult in
                    Task {
                        await subscriptionManager.checkSubscriptionStatus()
                        loadingStatus.1 = true
                    }
                }
                
                /// Privacy Policy & Terms of Service
                HStack(spacing: 3) {
                    Link("Terms of Service", destination: URL(string: "https://apple.com")!)

                    Text("And")

                    Link("Privacy Policy", destination: URL(string: "https://apple.com")!)
                }
                .font(.caption)
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(isLoadingCompleted ? 1 : 0)
            .background(BackdropView())
            .ignoresSafeArea()
            .overlay {
                if !isLoadingCompleted || subscriptionManager.isLoading {
                    ProgressView()
                        .font(.largeTitle)
                }
            }
            .overlay(alignment: .top) {
                // Error message overlay
                if let errorMessage = subscriptionManager.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(.red.opacity(0.8))
                            .cornerRadius(8)
                            .padding()
                        Spacer()
                    }
                    .onTapGesture {
                        subscriptionManager.errorMessage = nil
                    }
                    .onAppear {
                        // Auto-dismiss error message after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            subscriptionManager.errorMessage = nil
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.35), value: isLoadingCompleted)
            .animation(.easeInOut(duration: 0.25), value: subscriptionManager.isLoading)
            .storeProductsTask(for: Self.productIDs) { @MainActor collection in
                if let products = collection.products, products.count == Self.productIDs.count {
                    try? await Task.sleep(for: .seconds(0.1))
                    loadingStatus.0 = true
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .tint(.white)
        .statusBarHidden()
        .onAppear {
            // Reset loading states when view appears to prevent frozen state
            Task {
                // Small delay to ensure proper initialization
                try? await Task.sleep(for: .milliseconds(100))
                // Force refresh subscription status for expired users
                await subscriptionManager.checkSubscriptionStatus()
            }
        }
    }
    
    var isLoadingCompleted: Bool {
        loadingStatus.0 && loadingStatus.1
    }
    
    static var productIDs: [String] {
        return ["ordernisemonthly", "orderniseannual"]
    }
    
    /// Backdrop View
    @ViewBuilder
    func BackdropView() -> some View {
        GeometryReader {
            let size = $0.size
            
            /// This is a Dark image, but you can use your own image as per your needs!
            Image("IAP4")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .scaleEffect(1.5)
                .blur(radius: 70, opaque: true)
                .overlay {
                    Rectangle()
                        .fill(.black.opacity(0.2))
                }
                .ignoresSafeArea()
        }
    }
    
    /// Custom Marketing View (Header View)
    @ViewBuilder
    func CustomMarketingView() -> some View {
        VStack(spacing: 15) {
            /// App Screenshots View
            HStack(spacing: 25) {
                ScreenshotsView([.one, .two, .three], offset: -200)
                ScreenshotsView([.four, .one, .two], offset: -350)
                ScreenshotsView([.two, .three, .one], offset: -250)
                    .overlay(alignment: .trailing) {
                        ScreenshotsView([.four, .two, .one], offset: -150)
                            .visualEffect { content, proxy in
                                content
                                    .offset(x: proxy.size.width + 25)
                            }
                    }
            }
            .frame(maxHeight: .infinity)
            .offset(x: 20)
            /// Progress Blur Mask
            .mask {
                LinearGradient(colors: [
                    .white,
                    .white.opacity(0.9),
                    .white.opacity(0.7),
                    .white.opacity(0.4),
                    .clear
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .padding(.bottom, -40)
            }
            
            /// Replace with your App Information
            VStack(spacing: 6) {
                Text("Ordernise")
                    .font(.title3)
                
                Text("Membership")
                    .font(.largeTitle)
                
                Text("Never lose track of your business again.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(.white)
            .padding(.top, 15)
            .padding(.bottom, 18)
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func ScreenshotsView(_ content: [IAPImage], offset: CGFloat) -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 10) {
                ForEach(content.indices, id: \.self) { index in
                    Image(content[index].rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .offset(y: offset)
        }
        .scrollDisabled(true)
        .scrollIndicators(.hidden)
        .rotationEffect(.init(degrees: -30), anchor: .bottom)
        .scrollClipDisabled()
    }
}

#Preview {
    PaywallView()
}
