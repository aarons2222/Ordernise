//
//  FloatingTabView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
internal import Combine

protocol FloatingTabProtocol {
    var symbolImage: String {get}
}

fileprivate class FloatingTabViewHelper: ObservableObject {
    @Published var hideTabBar: Bool = false
}

fileprivate struct HideFloatingTabBarModeifier: ViewModifier{
    var status: Bool
    @EnvironmentObject private var helper: FloatingTabViewHelper
    func body(content: Content) -> some View {
        content
            .onChange(of: status, initial: true){ oldValue, newValue in
                
                
                helper.hideTabBar = newValue
            }
    }
}


extension View {
     func hideFloatingTabBar(_ status: Bool) -> some View {
         self
             .modifier(HideFloatingTabBarModeifier(status: status))
    }
}

struct FloatingTabView<Content: View, Value: CaseIterable & Hashable & FloatingTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    
    
    var config: FloatingTabConfig
    
    @Binding var selection: Value
    var content: (Value, CGFloat) -> Content
    
    @AppStorage("userTintHex") private var tintHex: String = "#007AFF"
    
    init(config: FloatingTabConfig = .init(), selection: Binding<Value>, @ViewBuilder content: @escaping (Value, CGFloat) -> Content) {
        self.config = config
        self._selection = selection
        self.content = content
    }
    
    @StateObject private var helper: FloatingTabViewHelper = .init()
    
    private var dynamicConfig: FloatingTabConfig {
        var updatedConfig = config
        updatedConfig.activeBackgroundTint = Color(hex: tintHex) ?? .color1
        return updatedConfig
    }
    
    
    var body: some View {
      
        
        ZStack(alignment: .bottom){
            if #available(iOS 18, *){
                TabView(selection: $selection){
                    
                    ForEach(Value.allCases, id: \.hashValue){ tab in
                        
                        
                        Tab.init(value: tab){
                            content(tab, 0)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        
                      
                    }
                }
            }else{
                TabView(selection: $selection){
                    
                    ForEach(Value.allCases, id: \.hashValue){ tab in
                        content(tab, 0)
                            .tag(tab)
                            .toolbar(.hidden, for: .tabBar)
                    }
                    
                }
            }
            
            
            FloatingTabBar(config: dynamicConfig, activeTab: $selection)
                .padding(.horizontal, config.hPadding)
                .padding(.bottom, config.bPadding)
        }
        .environmentObject(helper)
        
        
    }
}

struct FloatingTabConfig {
    var activeTint: Color = .white                      // Color of the active tab icon/text
    var activeBackgroundTint: Color = Color.appTint     // Background color of the active tab
    var inactiveTint: Color = .gray                     // Color of inactive tab icon/text
    var tabAnimation: Animation = .smooth(duration: 0.35, extraBounce: 0) // Animation config for tab switching
    var backgroundColor: Color = .gray.opacity(0.1)     // Background color of the tab bar
    var insetAmount: CGFloat = 6                        // Padding/inset for layout
    var isTranslucent: Bool = true                      // Determines if the tab bar is translucent
    var hPadding: CGFloat = 15
    var bPadding: CGFloat = 0
}




fileprivate struct FloatingTabBar<Value: CaseIterable & Hashable & FloatingTabProtocol>: View where
        Value.AllCases: RandomAccessCollection {
    
    
    var config: FloatingTabConfig
    @Binding var activeTab: Value
            
            
    @Namespace private var animation
            
@State private var toggleSymbolEffect: [Bool] = Array(repeating: false, count: Value.allCases.count)
            
    var body: some View{
        
        HStack(spacing: 0){
            ForEach(Value.allCases, id: \.hashValue){ tab in
                
                let isActive = activeTab == tab
                let index = (Value.allCases.firstIndex(of: tab) as? Int) ?? 0
                
                Image(systemName: tab.symbolImage)
                    .font(.title2)
                    .foregroundStyle(isActive ? config.activeTint : config.inactiveTint)
                    .symbolEffect(.bounce.byLayer.down, value: toggleSymbolEffect[index])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .background{
                        if isActive{
                            Capsule(style: .continuous)
                                .fill(config.activeBackgroundTint.gradient)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                   
                    .padding(.vertical, config.insetAmount)
                    .onTapGesture {
                        activeTab = tab
                        
                        
                        print("activeTab \(activeTab)")
                        toggleSymbolEffect[index].toggle()
                    }
                
            }
            .padding(.horizontal, config.insetAmount)
            .frame(height: 50)
            .background{
            
                
                    
                    Rectangle()
                    .fill(config.backgroundColor.opacity(0.9))
                
            }
 
        }
        .clipShape(.capsule(style: .continuous))
        .animation(config.tabAnimation, value: activeTab)
    }
}




#Preview {
    ContentView()
}


