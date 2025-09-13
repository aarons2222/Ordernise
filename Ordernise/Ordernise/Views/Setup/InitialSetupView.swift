//
//  InitialSetupView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 01/09/2025.
//

import SwiftUI
import SwiftData

/// OnBoarding Card
struct OnBoardingCard: Identifiable {
    var id: String = UUID().uuidString
    var symbol: String
    var title: String
    var subTitle: String
}

/// OnBoarding Card Result Builder
@resultBuilder
struct OnBoardingCardResultBuilder {
    static func buildBlock(_ components: OnBoardingCard...) -> [OnBoardingCard] {
        components.compactMap { $0 }
    }
}

struct InitialSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var hasCompletedInitialSetup: Bool
    
    @State private var isLoadingDummyData = false
    @State private var showingGuidedSetup = false
    @Environment(\.colorScheme) var colorScheme
    
    // OnBoarding Animation States
    @State private var animateIcon: Bool = false
    @State private var animateTitle: Bool = false
    @State private var animateCards: [Bool] = []
    @State private var animateFooter: Bool = false
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \StockItem.name) private var stockItems: [StockItem]
    
    private var logoImage: Image {
        colorScheme == .dark
            ? Image("LogoDark")
            : Image("Logo")
    }
    
    // Computed property to determine if setup is needed
    private var needsSetup: Bool {
        categories.isEmpty || stockItems.isEmpty
    }
    
    var body: some View {
        NavigationView {
            if showingGuidedSetup {
                VStack{
                    GuidedSetupView(hasCompletedInitialSetup: $hasCompletedInitialSetup)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showingGuidedSetup = false
                                } label: {
                                    Image(systemName: "chevron.backward.circle")
                                        .font(.title2)
                                }
                                .tint(Color.appTint)
                                .padding(.leading)
                            }
                        }
                    Spacer()
                }
            } else {
                // Initial OnBoarding Style Content
                VStack(spacing: 0) {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 20) {
                            // Logo Icon
                            logoImage
                                .resizable()
                                .frame(width: 120, height: 120)
                                .frame(maxWidth: .infinity)
                                .blurSlide(animateIcon)
                            
                            // Welcome Title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome to Ordernise!")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Text("Your complete order management solution")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .blurSlide(animateTitle)
                            
                            // OnBoarding Cards
                            OnBoardingCardsView()
                        }
                        .padding(.horizontal, 20)
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    
                    // Footer with action buttons
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            Text("How would you like to get started?")
                            
                                .multilineTextAlignment(.center)
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                // Use Sample Data Button
                                Button(action: loadDummyData) {
                                    HStack {
                                        if isLoadingDummyData {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "doc.text.below.ecg")
                                                .font(.headline)
                                        }
                                        
                                        Text(isLoadingDummyData ? "Loading..." : "Use Sample Data")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.appTint)
                                    )
                                }
                                .disabled(isLoadingDummyData)
                                
                                // Manual Setup Button
                                Button(action: setupApp) {
                                    HStack {
                                        Image(systemName: "gearshape.2")
                                            .font(.headline)
                                        
                                        Text("Set Up Manually")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.appTint)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                      Capsule()
                                            .fill(Color.appTint.opacity(0.1))
                                            .stroke(Color.appTint, lineWidth: 1)
                                    )
                                }
                                .disabled(isLoadingDummyData)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .blurSlide(animateFooter)
                    .padding(.horizontal, 20)
                }
           
                .allowsHitTesting(animateFooter)
                .task {
                    await startOnBoardingAnimation()
                }
                .navigationBarHidden(true)
            }
        }
        .onChange(of: hasCompletedInitialSetup) { _, completed in
            if completed {
                dismiss()
            }
        }
    }
    
    // MARK: - OnB
    
    
    
    
    
    /// OnBoarding Cards View
    @ViewBuilder
    func OnBoardingCardsView() -> some View {
        let cards = getOnBoardingCards()
        
        VStack(alignment: .leading, spacing: 20) {
            ForEach(cards.indices, id: \.self) { index in
                onBoardingCardView(for: cards[index], at: index)
            }
        }
    }
    
    @ViewBuilder
    private func onBoardingCardView(for card: OnBoardingCard, at index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: card.symbol)
                .font(.title2)
                .foregroundStyle(Color.appTint)
                .symbolVariant(.fill)
                .frame(width: 45)
                .offset(y: 10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(card.title)
                    .font(.title3)
                    .lineLimit(1)
                
                Text(card.subTitle)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
        }
        .blurSlide(index < animateCards.count ? animateCards[index] : false)
    }
    
    private func getOnBoardingCards() -> [OnBoardingCard] {
        [
            OnBoardingCard(
                symbol: "square.stack.3d.down.right.fill",
                title: "Order Management",
                subTitle: "Track orders from multiple platforms like eBay, Amazon, and Etsy all in one place"
            ),
            OnBoardingCard(
                symbol: "cube.box.fill",
                title: "Stock Control",
                subTitle: "Monitor inventory levels and get notified when items are running low"
            ),
            OnBoardingCard(
                symbol: "chart.line.uptrend.xyaxis",
                title: "Analytics & Insights",
                subTitle: "View detailed reports on sales, profit margins, and business performance"
            ),
            OnBoardingCard(
                symbol: "icloud.and.arrow.up.fill",
                title: "Cloud Sync",
                subTitle: "Access your data across all devices with automatic iCloud synchronization"
            )
        ]
    }
    
    private func startOnBoardingAnimation() async {
        guard !animateIcon else { return }
        
        let cards = getOnBoardingCards()
        animateCards = Array(repeating: false, count: cards.count)
        
        await delayedAnimation(isMac ? 0.1 : 0.35) {
            animateIcon = true
        }
        
        await delayedAnimation(0.2) {
            animateTitle = true
        }
        
        try? await Task.sleep(for: .seconds(0.2))
        
        for index in animateCards.indices {
            let delay = Double(index) * 0.1
            await delayedAnimation(delay) {
                animateCards[index] = true
            }
        }
        
        await delayedAnimation(0.2) {
            animateFooter = true
        }
    }
    
    func delayedAnimation(_ delay: Double, action: @escaping () -> ()) async {
        try? await Task.sleep(for: .seconds(delay))
        
        withAnimation(.smooth) {
            action()
        }
    }
    
    private var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    private func loadDummyData() {
        isLoadingDummyData = true
        
        // Simply enable dummy mode - don't persist data to avoid iCloud sync
        DummyDataManager.shared.isDummyModeEnabled = true
        
        // Brief delay for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasCompletedInitialSetup = true
            UserDefaults.standard.set(true, forKey: "hasCompletedInitialSetup")
            isLoadingDummyData = false
            dismiss()
        }
    }
    
    private func setupApp() {
        showingGuidedSetup = true
    }
}

// MARK: - Extensions

extension View {
    /// Custom Blur Slide Effect
    @ViewBuilder
    func blurSlide(_ show: Bool) -> some View {
        self
            /// Groups the view and adds blur to the grouped view rather than applying blur to each node view!
            .compositingGroup()
            .blur(radius: show ? 0 : 10)
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 100)
    }
}

#Preview {
    InitialSetupView(hasCompletedInitialSetup: .constant(false))
        .modelContainer(for: [Order.self, StockItem.self])
}
