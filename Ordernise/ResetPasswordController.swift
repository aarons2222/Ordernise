//
//  ResetPasswordController.swift
//  Ordernise
//
//  Created by Aaron on 26/07/2021.
//

import UIKit
import FirebaseAuth


class ResetPasswordController: UIViewController{
    @IBOutlet weak var resetuserPaqsswordTV: UITextField!

    
    override func viewDidLoad() {
        
    }
    
    @IBAction func resetPassword(_ sender: Any) {
   
        
        guard let email = resetuserPaqsswordTV.text, !email.isEmpty else{
            
            DispatchQueue.main.async {
                self.showError(message: "Please provide a valid email address", dismiss: false, toLogin: false)            }
            
            
            // error with login
            
            print("loginn failed")
            return
        }
        
        
        
        
        
        Auth.auth().sendPasswordReset(withEmail: "email@email") { error in
            // Your code here
            
            if error != nil {

                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    print("Error \(errCode)")

                             switch errCode {
                          
                             case .invalidEmail:
                                DispatchQueue.main.async {
                                    print("User does not exist")
                                    self.showError(message: "Please provide a valid email address", dismiss: true, toLogin: false)
                                }
                                
                          
                               
                                 default:
                                     print("Create User Error: \(error!)")
                             }
                         }

                     } else {
                        self.showError(message: "THanks you, if your account is retreived, you will receive reset instructions", dismiss: true, toLogin: true)

                     }
            
            
            
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    @IBAction func toLogin(_ sender: Any) {
        self.performSegue(withIdentifier: "unwind", sender: self)

    }
    
    
    
    
    func showError(message: String, dismiss: Bool, toLogin: Bool) {
            
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        if dismiss {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                            
                
                if toLogin{
                    self.performSegue(withIdentifier: "unwind", sender: self)
                }

            }))
        }
        self.present(alert, animated: true, completion: nil)
   
    }

    
    
}
