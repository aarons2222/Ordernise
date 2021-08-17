//
//  AppDelegate.swift
//  Ordernise
//
//  Created by Aaron on 18/07/2021.
//

import UIKit
import Firebase
import HapticGenerator
import FirebaseAuth
import IQKeyboardManagerSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
    
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            //if app is first time opened then it will be nil
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
            // signOut from FIRAuth
            do {
                try Auth.auth().signOut()
            }catch {

            }
            // go to beginning of app
        } else {
           //go to where you want
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension UIViewController {
    @IBAction func unwind(_ segue: UIStoryboardSegue) {}
    
 
     
        func popupAlert(message: String, dismiss: Bool) {
                
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            if dismiss {
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                }))
            }
            self.present(alert, animated: true, completion: nil)
        }
    
    func generateHaptics(){
        let lightImpact = Haptic(.impact(.medium))
        lightImpact.generate()
    }
    
    
    
    func saveImage(imageName: String, image: UIImage) {

     guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }

    }

    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {

      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
    }
    
    
    
    func addBottomBorder(textView: UITextField){
          let bottomLine = CALayer()
          
          bottomLine.frame = CGRect(x: 0, y: textView.frame.height - 1, width: textView.frame.width, height: 0.5)
              bottomLine.backgroundColor = UIColor.gray.cgColor
          textView.borderStyle = .none

          textView.backgroundColor = UIColor.clear
          textView.layer.addSublayer(bottomLine)
          }
    
    
    func showAlert(title: String, message: String, toSettings: Bool){
        
        
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
         
            if toSettings{
                
               // backtosettings
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "backtosettings", sender: nil)
                }
                
            }
        
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    

}


extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
}




extension UIView{
    
    func RightTopBottomCorner(radius : CGFloat){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .bottomRight],
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func LeftTopBottomCorner(radius : CGFloat){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
                                     cornerRadii: CGSize(width: radius, height:radius))
        let maskLayer1 = CAShapeLayer()
        // maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    
    func myRound(radius : CGFloat){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft],
                                     cornerRadii: CGSize(width: radius, height:radius))
      
        
        let maskLayer1 = CAShapeLayer()
        // maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }

    
}





extension UIView{
    
    func setShadow() {
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        self.layer.shadowRadius = 10.0
        self.layer.shadowOpacity = 0.7666
    }
    
    
}


