//
//  SettingsView.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @StateObject private var localeManager = LocaleManager.shared
    @StateObject private var dummyDataManager = DummyDataManager.shared
    @AppStorage("userTintHex") private var tintHex: String = "#ACCDFF"
    @State private var selectedColor: Color = .color1
    
    @State private var showingSupport = false
    
    
    @AppStorage("AppTheme") private var appTheme: AppTheme = .systemDefault
 

    
    var body: some View {
        
        NavigationStack{
            
            
            VStack {
              
                
                
                HeaderWithButton(
                    title: String(localized: "Settings"),
                    buttonContent: "line.3.horizontal.decrease.circle",
                    isButtonImage: true,
                    showTrailingButton: false,
                    showLeadingButton: false,
                    onButtonTap: {
                  
                        
                    }
                )
                
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 15) {
                        
                        VStack(alignment: .leading){
                         
                        
                    SectionHeader(title: String(localized: "General"))
                          
                            
                            CustomCardView{
                                
                                
                                HStack{
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(String(localized: "Currency"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text(String(localized: "This currency will be used for new stock items"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        
                                    }
                                    Spacer()
                                    
                                    
                                    Menu {
                                        ForEach(Currency.allCases, id: \.rawValue) { currency in
                                            Button {
                                                localeManager.setCurrency(currency)
                                            } label: {
                                                Text(" \(localeManager.getCurrencySymbol(for: currency))  \(localeManager.getCurrencyDisplayName(for: currency))")
                                                    .font(.title2)
                                                
                                                
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            
                                            Text(localeManager.getCurrencySymbol(for: localeManager.currentCurrency))
                                                .font(.title)
                                                .foregroundStyle(Color.appTint)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.title3)
                                                .tint(Color.appTint)
                                        }
                                    }
                                    
                                }
                                
                                
                            }
                            .padding(.bottom, 3)
                            
                            CustomCardView{
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                 
                                        Text(String(localized: "Dummy Mode"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                   
                                
                                    
                                    Text(dummyDataManager.isDummyModeEnabled ? 
                                        String(localized: "Using 100 test orders from the last year for demonstration purposes") : 
                                        String(localized: "Use realistic test data instead of your actual business data"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                               
                                    Toggle("", isOn: $dummyDataManager.isDummyModeEnabled)
                                        .labelsHidden()
                                        .tint(Color.appTint)
                                    
                              
                                
                            }
                        }
                        
                        
                        
                        
                        }
                        
                        
                        
                        
                        VStack(alignment: .leading){
                     

                            SectionHeader(title: String(localized: "Workflow Settings"))
                            
                            
                            
                            NavigationLink(destination: OrderStatusOptions()) {
                                
                                CustomCardView(String(localized: "Order Settings")) {
                                    
                                    HStack(alignment: .center){
                                        
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Order Status Options"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            
                                            
                                            Text(String(localized: "Select which statuses are available in your order workflow."))
                                            
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)
                                    }
                                    
                                }
                            }
                            
                            
                            
                            
                            NavigationLink(destination: PlatformOptions()) {
                                
                                CustomCardView {
                                    
                                    HStack{
                                        
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Platform Options"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            
                                            
                                            Text(String(localized: "Select which platforms are available in your order workflow."))
                                            
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                    
                                }.padding(.vertical, 3)
                            }
                            
                         
                            
                            NavigationLink(destination: CategoryOptions().enableSwipeBack()) {
                                CustomCardView{
                                    
                                    HStack{
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Categories"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Organise your stock items by category to keep things easy to find."))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                }
                            }
                            
                        }
                        
                        
                        
                        
                        
                        
                       
                        
                   
                        
                 
                  
                        
                        VStack(alignment: .leading){
                         
                            
                            
                  

                            
                            SectionHeader(title: String(localized: "Form Fields"))
                            
                            NavigationLink(destination: OrderFieldSettings()) {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Order Fields"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Customise which fields are shown when creating and editing orders"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                }
                                .padding(.bottom, 3)
                            }
                        
                            
                            
                            
                            
                            NavigationLink(destination: StockFieldSettings()) {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Stock Fields"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Customise which fields are shown when creating and editing stock items."))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)

                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                   
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        VStack(alignment: .leading){
                        
                            
                  
                            
                            SectionHeader(title: String(localized: "Data"))
                            

                            
                            NavigationLink(destination: ExportDataView()) {
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Export Data"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Export your orders and inventory data to Excel or CSV format for analysis and backup."))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)
                                    }
                                }
                            }
                        }
                        
                        
                        VStack(alignment: .leading){
                      
                            
                            
                            SectionHeader(title: String(localized: "Appearance"))
                             
                            
                            
                            CustomCardView {
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String(localized: "App Theme"))
                                        .font(.headline)
                                        .foregroundColor(.text)
                                    
                                    
                                    Text(String(localized: "Pick your favorite theme, or let the app follow your device settings."))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    SegmentedControl(
                                        tabs: AppTheme.allCases,
                                        activeTab: $appTheme,
                                        height: 35,
                                        font: .callout,
                                        activeTint: Color(UIColor.systemBackground),
                                        inActiveTint: .gray.opacity(0.8)
                                    ) { size in
                                        RoundedRectangle(cornerRadius: 22.5)
                                            .fill(Color.appTint.gradient)
                                   
                                    }
                                    .background(
                                        Capsule()
                                            .fill(Color.gray.opacity(0.1))
                                            .stroke(Color.appTint, lineWidth: 3)
                                    )
                                 
                                    .padding(.vertical)
                                    
                                    
                                    
                                    
//                                    
//                                    Picker("", selection: $appTheme){
//                                        
//                                        ForEach(AppTheme.allCases, id: \.rawValue){ theme in
//                                                    
//                                            Text(theme.rawValue)
//                                                .tag(theme)
//                                        }
//                                    }
//                                    .pickerStyle(.segmented)
                                    
                                    
                                    
                                }
                                
                            }
                            .padding(.bottom, 3)
                            
                            CustomCardView {
                                
                                
                                
                                
                                
                                
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(String(localized: "App Tint"))
                                            .font(.headline)
                                            .foregroundColor(.text)
                                        
                                        Text(String(localized: "Pick a color to customise the app's look - some colours may make some UI elements unreadable."))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    ColorPicker("", selection: Binding(
                                        get: { Color(hex: tintHex) ?? .color1 },
                                        set: { color in
                                            DispatchQueue.main.async {
                                                tintHex = color.toHex()
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                }
                            }
                            
                            
                        }
                 
                        
                        
                        
                        VStack(alignment: .leading){
                     
                            SectionHeader(title: String(localized: "Support"))
                               

                            Button{
                                self.showingSupport = true
                            }label: {
                            
                    
                                CustomCardView {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: "Support"))
                                                .font(.headline)
                                                .foregroundColor(.text)
                                            
                                            Text(String(localized: "Get support here"))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                            .font(.title2)
                                            .tint(Color.appTint)
                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                        
                        
                        Color.clear.frame(height: 60)
                    }
                    
                
            }
            .padding(.horizontal, 20)
  
        }
            
           .navigationBarHidden(true)
           .onAppear {
                       selectedColor = Color(hex: tintHex) ?? .color1
                   }
         
    }
        
     
            .fullScreenCover(isPresented: $showingSupport) {
                SupportView()
            }
    }
    


    

}

#Preview {
    SettingsView()
}













struct SwipeBackEnabledView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            if let navController = controller.navigationController {
                navController.interactivePopGestureRecognizer?.isEnabled = true
                navController.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension View {
    func enableSwipeBack() -> some View {
        self.background(SwipeBackEnabledView().frame(width: 0, height: 0))
    }
}
