//
//  FloatingTabView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
internal import Combine



struct CustomTabBar: View {
    @Binding var activeTab: AppTab
    @Binding var searchText: String
    var onSearchBarExpanded: (Bool) -> ()
    var onSearchTextFieldActive: (Bool) -> ()
    /// View Properties
    @GestureState private var isActive: Bool = false
    @State private var isInitialOffsetSet: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragOffset: CGFloat?
    /// Search Bar Properties
    @State private var isSearchExpanded: Bool = false
    @FocusState private var isKeyboardActive: Bool
    // Computed property for search bar visibility
    private var showsSearchBar: Bool {
        // List the tabs that should have search
        return activeTab == .orders || activeTab == .stock
    }
    
    
    
    private var placeholderText: String {
        switch activeTab {
        case .orders:
            return "Search orders..."
        case .stock:
            return "Search stock..."
        default:
            return "Search..."
        }
    }
    
    

    var body: some View {
        GeometryReader {
            let size = $0.size
            let tabs = AppTab.allCases.prefix(showsSearchBar ? 4 : 5)
            let tabItemWidth = max(min(size.width / CGFloat(tabs.count + (showsSearchBar ? 1 : 0)), 90), 60)
            let tabItemHeight: CGFloat = 56

            ZStack {
                if isInitialOffsetSet {
                    let mainLayout = isKeyboardActive ? AnyLayout(ZStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(spacing: 12))
                    
                    mainLayout {
                        let tabLayout = isSearchExpanded ? AnyLayout(ZStackLayout()) : AnyLayout(HStackLayout(spacing: 0))
                        
                        tabLayout {
                            ForEach(tabs, id: \.rawValue) { tab in
                                TabItemView(
                                    tab,
                                    width: isSearchExpanded ? 45 : tabItemWidth,
                                    height: isSearchExpanded ? 45 : tabItemHeight
                                )
                                .opacity(isSearchExpanded ? (activeTab == tab ? 1 : 0) : 1)
                            }
                        }
                     
                        .padding(3)
                        .background(TabBarBackground())
                        .opacity(isKeyboardActive ? 0 : 1)

                        // 🔹 Animated Search Bar
                        if showsSearchBar {
                            ExpandableSearchBar(height: isSearchExpanded ? 45 : tabItemHeight)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.25), value: showsSearchBar)
                        }
                    }
                    .optionalGeometryGroup()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                guard !isInitialOffsetSet else { return }
                let displayedTabs = Array(AppTab.allCases.prefix(showsSearchBar ? 4 : 5))
                let activeTabPosition = displayedTabs.firstIndex(of: activeTab) ?? 0
                dragOffset = CGFloat(activeTabPosition) * tabItemWidth
                isInitialOffsetSet = true
            }

        }
        .frame(height: 50)
        .padding(.horizontal, 25)
        .padding(.bottom, isKeyboardActive ? 10 : -20)
        .animation(.bouncy, value: dragOffset)
        .animation(.bouncy, value: isActive)
        .animation(.smooth, value: activeTab) // This animates tab change
        .animation(.easeInOut(duration: 0.25), value: isKeyboardActive)
        .customOnChange(value: isKeyboardActive) {
            onSearchTextFieldActive($0)
        }
        .customOnChange(value: isSearchExpanded) {
            onSearchBarExpanded($0)
        }


    }
    @State private var tappedTab: AppTab? = nil

    
    /// Tab Item View
    @ViewBuilder
    private func TabItemView(_ tab: AppTab, width: CGFloat, height: CGFloat) -> some View {
        let tabs = AppTab.allCases.prefix(showsSearchBar ? 4 : 5)
        let tabCount = tabs.count - 1
        let tabPosition = Array(tabs).firstIndex(of: tab) ?? 0
        
        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .font(.title2)
                .scaleEffect(tappedTab == tab ? 1.2 : 1.0)
                     .animation(.spring(response: 0.3, dampingFraction: 0.4), value: tappedTab)
            
         
        }
        .foregroundStyle(
            (activeTab == tab && !isSearchExpanded) || isSearchExpanded
            ? Color.appTint
            : Color.gray.opacity(0.8)
        )
        .frame(width: width, height: height)
        .contentShape(.capsule)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isActive, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    let xOffset = value.translation.width
                    if let lastDragOffset {
                        let newDragOffset = xOffset + lastDragOffset
                        dragOffset = max(min(newDragOffset, CGFloat(tabCount) * width), 0)
                    } else {
                        lastDragOffset = dragOffset
                    }
                })
                .onEnded({ value in
                    lastDragOffset = nil
                    /// Identifying the landing index
                    let landingIndex = Int((dragOffset / width).rounded())
                    /// Safe-Check
                    if tabs.indices.contains(landingIndex) {
                        dragOffset = CGFloat(landingIndex) * width
                        activeTab = tabs[landingIndex]
                    }
                })
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    tappedTab = tab
                    activeTab = tab
                    dragOffset = CGFloat(tabPosition) * width
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                  tappedTab = nil
                              }
                    
                    if isSearchExpanded {
                        withAnimation(.bouncy) {
                            isSearchExpanded = false
                        }
                        isKeyboardActive = false
                        searchText = ""
                    }
                }
        )
        .optionalGeometryGroup()
    }
    
    /// Tab Bar Background View
    @ViewBuilder
    private func TabBarBackground() -> some View {
        ZStack {
            Capsule(style: .continuous)
                .stroke(.gray.opacity(0.25), lineWidth: 1.5)
                        
            Capsule(style: .continuous)
                .fill(.background.opacity(0.8))
            
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .compositingGroup()
    }
    
    /// Expandable Search Bar
    @ViewBuilder
    private func ExpandableSearchBar(height: CGFloat) -> some View {
        let searchLayout = isKeyboardActive ? AnyLayout(HStackLayout(spacing: 12)) : AnyLayout(ZStackLayout(alignment: .trailing))
        
        searchLayout {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(isSearchExpanded ? .body : .title2)
                    .foregroundStyle(isSearchExpanded ? .gray : Color.primary)
                    .frame(width: isSearchExpanded ? nil : height, height: height)
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            isSearchExpanded = true
                        }
                    }
                    .allowsHitTesting(!isSearchExpanded)
                
                if isSearchExpanded {
                    TextField(placeholderText, text: $searchText)
                        .focused($isKeyboardActive)
                }
            }
            .padding(.horizontal, isSearchExpanded ? 15 : 0)
            .background(TabBarBackground())
            .optionalGeometryGroup()
            .zIndex(1)
            
            /// Close Button
            Button {
                searchText = ""
                isKeyboardActive = false
             
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(Color.primary)
                    .frame(width: height, height: height)
                    .background(TabBarBackground())
            }

            .opacity(isKeyboardActive ? 1 : 0)
        }
    }
    
    var accentColor: Color {
        return .blue
    }
}
