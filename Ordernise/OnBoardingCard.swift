//
//  OnBoardingCard.swift
//  Ordernise
//
//  Created by Aaron Strickland on 19/08/2025.
//




import SwiftUI
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

struct OnBoardingView<Icon: View, Footer: View>: View {
    var tint: Color
    var title: String
    var icon: Icon
    var cards: [OnBoardingCard]
    var footer: Footer
    var onContinue: () -> ()
    
    init(
        tint: Color,
        title: String,
        @ViewBuilder icon: @escaping () -> Icon,
        @OnBoardingCardResultBuilder cards: @escaping () -> [OnBoardingCard],
        @ViewBuilder footer: @escaping () -> Footer,
        onContinue: @escaping () -> Void
    ) {
        self.tint = tint
        self.title = title
        self.icon = icon()
        self.cards = cards()
        self.footer = footer()
        self.onContinue = onContinue
        
        /// Setting up the array count to match up with the card count
        self._animateCards = .init(initialValue: Array(repeating: false, count: self.cards.count))
    }
    
    /// View Properties
    @State private var animateIcon: Bool = false
    @State private var animateTitle: Bool = false
    @State private var animateCards: [Bool]
    @State private var animateFooter: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    icon
                        .frame(maxWidth: .infinity)
                        .blurSlide(animateIcon)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .blurSlide(animateTitle)
                    
                    CardsView()
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            
            VStack(spacing: 0) {
                footer
                
                /// Continue Button
                Button(action: onContinue) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    #if os(macOS)
                        .padding(.vertical, 8)
                    #else
                        .padding(.vertical, 4)
                    #endif
                }
                .tint(tint)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.bottom, 10)
            }
            .blurSlide(animateFooter)
        }
        /// Limiting to 330 in Width
        .frame(maxWidth: 330)
        /// Disabling Interactive Dismissal
        .interactiveDismissDisabled()
        /// Disabling interaction until footer is animated
        .allowsHitTesting(animateFooter)
        .task {
            guard !animateIcon else { return }
            
            await delayedAnimation(isMac ? 0.1 : 0.35) {
                animateIcon = true
            }
            
            await delayedAnimation(0.2) {
                animateTitle = true
            }
            
            try? await Task.sleep(for: .seconds(0.2))
            
            for index in animateCards.indices {
                /// YOUR DELAY VALUE HERE
                let delay = Double(index) * 0.1
                await delayedAnimation(delay) {
                    animateCards[index] = true
                }
            }
            
            await delayedAnimation(0.2) {
                animateFooter = true
            }
        }
        .setUpOnBoarding()
    }
    
    /// Cards View
    func CardsView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(cards.indices, id: \.self) { index in
                cardView(for: index)
            }
        }
    }
    
    @ViewBuilder
    private func cardView(for index: Int) -> some View {
        let card = cards[index]
        
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: card.symbol)
                .font(.title2)
                .foregroundStyle(tint)
                .symbolVariant(.fill)
                .frame(width: 45)
                .offset(y: 10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(card.title)
                    .font(.title3)
                    .lineLimit(1)
                
                Text(card.subTitle)
                    .lineLimit(2)
            }
        }
        .blurSlide(animateCards[index])
    }
    
    func delayedAnimation(_ delay: Double, action: @escaping () -> ()) async {
        try? await Task.sleep(for: .seconds(delay))
        
        withAnimation(.smooth) {
            action()
        }
    }
}

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
    
    @ViewBuilder
    fileprivate func setUpOnBoarding() -> some View {
        #if os(macOS)
        self
            .padding(.horizontal, 20)
            .frame(minHeight: 600)
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            /// Making it to be fitted on iPadOS 18+ devices
            if #available(iOS 18, *) {
                self
                    .presentationSizing(.fitted)
                    .padding(.horizontal, 25)
            } else {
                self
                    .padding(.bottom, 15)
            }
        } else {
            self
        }
        #endif
    }
    
    fileprivate var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
}

#Preview {
    ContentView()
}
