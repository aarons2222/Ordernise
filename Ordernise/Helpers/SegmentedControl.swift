//
//  SegmentedControl.swift
//  Ordernise
//
//  Created by Aaron Strickland on 04/08/2025.
//


import SwiftUI


struct SegmentedControl<Indicator: View, Tab: RawRepresentable & CaseIterable & Equatable & Hashable>: View where Tab.RawValue == String {
    var tabs: [Tab]
    @Binding var activeTab: Tab
    var height: CGFloat = 45
    var extraText: ((Tab) -> String)?
    var customText: ((Tab) -> String)? // Custom text provider for localization
    /// Customization Properties
    var displayAsText: Bool = false
    var font: Font = .footnote
    var activeTint: Color
    var inActiveTint: Color
    /// Indicator View
    @ViewBuilder var indicatorView: (CGSize) -> Indicator
    /// View Properties
    @State private var excessTabWidth: CGFloat = .zero
    @State private var minX: CGFloat = .zero
    
    // Observe tint color changes for reactive updates
    @AppStorage("userTintHex") private var tintHex: String = "#007AFF"
    
    // Dynamic colors that update with tint changes
    private var dynamicActiveTint: Color {
        // If the current activeTint is the system background, keep it reactive to system changes
        // Otherwise use the app tint for better visibility
        activeTint == Color(UIColor.systemBackground) ? Color(UIColor.systemBackground) : Color(hex: tintHex) ?? .color1
    }
    
    private var dynamicInActiveTint: Color {
        // Ensure inactive tint is always properly resolved for current color scheme
        Color(UIColor.secondaryLabel)
    }
    


    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let containerWidthForEachTab = size.width / CGFloat(tabs.count)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                     Group {
                         let displayText = customText?(tab) ?? tab.rawValue
                         if let extraText = extraText?(tab) {
                             Text("\(displayText) \(extraText)")
                                 .lineLimit(1)
                                 .minimumScaleFactor(0.7)
                             
                              
                         } else {
                             Text(displayText)
                            
                         }
                     }
                    .font(font)
                    .foregroundStyle(activeTab == tab ? dynamicActiveTint : dynamicInActiveTint)
                    .animation(.snappy, value: activeTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        DispatchQueue.main.async{
                            if let index = tabs.firstIndex(of: tab), let activeIndex = tabs.firstIndex(of: activeTab) {
                                activeTab = tab
                                
                                withAnimation(.snappy(duration: 0.45, extraBounce: 0), completionCriteria: .logicallyComplete) {
                                    excessTabWidth = containerWidthForEachTab * CGFloat(index - activeIndex)
                                } completion: {
                                    withAnimation(.snappy(duration: 0.45, extraBounce: 0)) {
                                        minX = containerWidthForEachTab * CGFloat(index)
                                        excessTabWidth = 0
                                    }
                                }
                            }
                        }
                    }
                    .background(alignment: .leading) {
                        if tabs.first == tab {
                            GeometryReader { proxy in
                                let size = proxy.size
                                
                                indicatorView(size)
                                    .frame(width: size.width + (excessTabWidth < 0 ? -excessTabWidth : excessTabWidth), height: size.height)
                                    .frame(width: size.width, alignment: excessTabWidth < 0 ? .trailing : .leading)
                                    .offset(x: minX)
                            }
                        }
                    }
                }
            }
         
            .preference(key: SizeKey.self, value: size)
            .onPreferenceChange(SizeKey.self) { size in
                if let index = tabs.firstIndex(of: activeTab) {
                    minX = containerWidthForEachTab * CGFloat(index)
                    excessTabWidth = 0
                }
            }
        }
        .frame(height: height)
        
    }
}


fileprivate struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}



