//
//  ChangePasswordController.swift
//  Ordernise
//
//  Created by Aaron on 01/08/2021.
//

import UIKit
import FirebaseAuth

class ChangePasswordController: UIViewController{

    
    
    @IBOutlet weak var passwordField: FloatingTextField!
    @IBOutlet weak var newPasswordField: FloatingTextField!
    @IBOutlet weak var convirmNewPasswordField: FloatingTextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        changePasswordButton.isEnabled = false
       
        convirmNewPasswordField.addTarget(self, action: #selector(yourHandler(textField:)), for: .editingChanged)


    }
    
    
    
    @objc final private func yourHandler(textField: UITextField) {
       
        if convirmNewPasswordField.text!.count > 7{
            changePasswordButton.isEnabled = true

        }else{
            changePasswordButton.isEnabled = false

        }
    }
    
    
    @IBAction func SubmittPasswordChangeBtn(_ sender: Any) {
       
        print("bob")
        
        
        
        let newPassword = newPasswordField.text!
        let confNewPassword = convirmNewPasswordField.text!
        
        
        
        
        
        let password = passwordField.text!
        
        if newPassword.count > 7{
         
       print("bob1")
            
            // alert user password is to short
            
            
            
            
            if newPassword != confNewPassword{
           
                
                self.showAlert(title: "Error", message: "New passwords do not match", toSettings: false)
                
                newPasswordField.text = ""
                convirmNewPasswordField.text = ""
            } else{
                
                let email = Auth.auth().currentUser?.email
                
                Auth.auth().signIn(withEmail: email!, password: password) { (user, error) in
                    if error == nil {
     
                        // reauthenticated successfully, no update password
                        Auth.auth().currentUser?.updatePassword(to: confNewPassword) { error in
                
                            if error != nil {

                                if let errCode = AuthErrorCode(rawValue: error!._code) {
                                         }
                            }else{
                                //
                                self.showAlert(title: "Success", message: "Your password has been updated", toSettings: true)
                                
                                print("password change was successful")
                            }
                        }
                    } else {
                      //handle error
                  // failed to re authenticate
                        self.passwordField.text = ""
                        self.newPasswordField.text = ""
                        self.convirmNewPasswordField.text = ""
                        print("AUTHERROR \(error)")
                        
                        self.showAlert(title: "Something went wrong", message: "Please try again", toSettings: false)
                    }
                  }
                
                
                
         
                
                
            }
            
          
            
            
        }else{
            
            //passwords are too short
            
        }


    }
    
    
    
    
  
    
    
    func logOut(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
         
            
            do {
                try Auth.auth().signOut()
                
            }catch {

            }
            ///returnToLogin
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "returnToLogin", sender: nil)
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
        
    
    }
    
    let customBlue = UIColor(named: "CustomBlue")
    
}



