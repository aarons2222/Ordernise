//
//  ChangePasswordController.swift
//  Ordernise
//
//  Created by Aaron on 01/08/2021.
//

import UIKit
import TweeTextField
import FirebaseAuth

class ChangePasswordController: UIViewController{

    
    
    
    @IBOutlet weak var passwordField: TweeAttributedTextField!
    @IBOutlet weak var newPasswordField: TweeAttributedTextField!
    @IBOutlet weak var convirmNewPasswordField: TweeAttributedTextField!
    
    
    @IBAction func SubmittPasswordChangeBtn(_ sender: Any) {
       
        
        let password = passwordField.text!
        let newPassword = newPasswordField.text!
        let confNewPassword = convirmNewPasswordField.text!
        
        
        
        
        if password.count < 7{
            passwordField.infoLabel.isHidden = false
            passwordField.text = ""
            passwordField.infoLabel.text = "Too Short"
            
        }
       
        
        
        
//        Auth.auth().currentUser?.updatePassword(to: confNewPassword) { error in
//
//            print("erroor \(error)")
//          // ...
//        }
    

    }
    
    
    let customBlue = UIColor(named: "CustomBlue")
    
    override func viewDidLoad() {
        

       
        setUpTextViews()
        
        


    }
    


    
    
    
    func setUpTextViews(){
        
        
        passwordField.infoAnimationDuration = 0.7
        passwordField.infoTextColor = .systemRed
     
        passwordField.infoFontSize = 13
        passwordField.activeLineColor = customBlue!
        passwordField.activeLineWidth = 2
        passwordField.animationDuration = 0.6
        passwordField.lineColor = .lightGray
        passwordField.lineWidth = 2
        passwordField.minimumPlaceholderFontSize = 13
        passwordField.originalPlaceholderFontSize = 16
        passwordField.placeholderDuration = 0.3
        passwordField.placeholderColor = .systemGray2
        passwordField.tweePlaceholder = "Password"
        
        
        
        
        newPasswordField.infoAnimationDuration = 0.7
        newPasswordField.infoTextColor = .systemRed
        newPasswordField.infoFontSize = 13
        newPasswordField.activeLineColor = customBlue!
        newPasswordField.activeLineWidth = 2
        newPasswordField.activeLineWidth = 2
        newPasswordField.animationDuration = 0.6
        newPasswordField.lineColor = .lightGray
        newPasswordField.lineWidth = 2
        newPasswordField.minimumPlaceholderFontSize = 12
        newPasswordField.originalPlaceholderFontSize = 16
        newPasswordField.placeholderDuration = 0.3
        newPasswordField.placeholderColor = .systemGray2
        newPasswordField.tweePlaceholder = "New Password"

        
        
        convirmNewPasswordField.infoAnimationDuration = 0.7
        convirmNewPasswordField.infoTextColor = .systemRed
        convirmNewPasswordField.infoFontSize = 13
        convirmNewPasswordField.activeLineColor = customBlue!
        convirmNewPasswordField.activeLineWidth = 2
        convirmNewPasswordField.activeLineWidth = 2
        convirmNewPasswordField.animationDuration = 0.6
        convirmNewPasswordField.lineColor = .lightGray
        convirmNewPasswordField.lineWidth = 2
        convirmNewPasswordField.minimumPlaceholderFontSize = 12
        convirmNewPasswordField.originalPlaceholderFontSize = 16
        convirmNewPasswordField.placeholderDuration = 0.3
        convirmNewPasswordField.placeholderColor = .systemGray2
        convirmNewPasswordField.tweePlaceholder = "Confirm New Password"

    }
    
}
