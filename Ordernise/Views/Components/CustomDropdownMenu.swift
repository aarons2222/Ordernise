import SwiftUI

struct CustomDropdownMenu<T: Hashable>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
    let optionToString: (T) -> String
    let optionToColor: ((T) -> Color)?
    let optionToImage: ((T) -> Image)?
    let systemImage: Image?
    
    @State private var isExpanded: Bool = false
    
    init(
        title: String,
        options: [T],
        selection: Binding<T>,
        optionToString: @escaping (T) -> String,
        optionToColor: ((T) -> Color)? = nil,
        optionToImage: ((T) -> Image)? = nil,
        systemImage: Image? = nil
    ) {
        self.title = title
        self.options = options
        self._selection = selection
        self.optionToString = optionToString
        self.optionToColor = optionToColor
        self.optionToImage = optionToImage
        self.systemImage = systemImage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Menu Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    if let systemImage = systemImage {
                        systemImage
                            .foregroundStyle(Color.appTint)
                    }
                    
                    if let optionToImage = optionToImage {
                        optionToImage(selection)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    }
                    
                    if let optionToColor = optionToColor {
                        let iconName = optionToString(selection) == "Manage Categories..." ? "plus.circle" : "largecircle.fill.circle"
                        Image(systemName: iconName)
                            .foregroundColor( optionToString(selection) == "Manage Categories..." ? Color.appTint : optionToColor(selection))
                             .frame(width: 28, height: 28)
                    }
                    
                    Text(optionToString(selection))
                        .foregroundStyle(.primary)
                     
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down.circle")
                        .foregroundStyle(Color.appTint)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
           
                .padding(.horizontal)
                .padding(.vertical, 13)
                .background(
                   Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .stroke(Color.appTint, lineWidth: 2)
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)

            }
            .buttonStyle(PlainButtonStyle())
            
            // Dropdown Content
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                if let optionToImage = optionToImage {
                                    optionToImage(option)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                        .foregroundColor((option as? Platform) == .custom ? Color.appTint : nil)
                                }
                                
                                
                                if let optionToColor = optionToColor {
                                    let iconName = optionToString(option) == "Manage Categories..." ? "plus.circle" : "largecircle.fill.circle"
                                    Image(systemName: iconName)
                                        .foregroundStyle(optionToColor(option))
                                        .frame(width: 28, height: 28)
                                }
                                
                                Text(optionToString(option))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if option == selection {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(Color.appTint)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(option == selection ? Color.appTint.opacity(0.1) : .clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if option != options.last {
                            Divider()
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.top, 4)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9, anchor: .top).combined(with: .opacity),
                    removal: .scale(scale: 0.9, anchor: .top).combined(with: .opacity)
                ))
            }
        }
        .zIndex(isExpanded ? 1000 : 0)
    }
}

// Custom dropdown specifically for OrderStatus
struct StatusDropdownMenu: View {
    @Binding var selection: OrderStatus
    
    var body: some View {
        CustomDropdownMenu(
            title: "Status",
            options: OrderStatus.enabledCases,
            selection: $selection,
            optionToString: { $0.rawValue.capitalized },
            optionToColor: { $0.statusColor }
        )
    }
}

// Custom dropdown specifically for Platform
struct PlatformDropdownMenu: View {
    @Binding var selection: Platform
    
    private func platformIcon(for platform: Platform) -> Image {
        switch platform {
        case .amazon:
            return Image("amazon")
        case .ebay:
            return Image("ebay")
        case .carboot:
            return Image(systemName: "car.side.rear.open")
        case .depop:
            return Image("depop")
        case .shopify:
            return Image("shopify")
        case .etsy:
            return Image("etsy")
        case .custom:
            return Image(systemName: "wrench.adjustable")
        case .vinted:
            return Image("vinted")
        case .poshmark:
            return Image("poshmark")
        case .marketplace:
            return Image("facebook")
        case .gumtree:
            return Image("gumtree")
        }
    }
    
    var body: some View {
        CustomDropdownMenu(
            title: "Platform",
            options: Platform.allCases,
            selection: $selection,
            optionToString: { $0.rawValue.capitalized },
            optionToImage: { platformIcon(for: $0) }
        )
    }
}

#Preview {
    VStack {
        StatusDropdownMenu(selection: .constant(.received))
        Spacer()
    }
    .padding()
}
