//
//  ResetPasswordController.swift
//  Ordernise
//
//  Created by Aaron on 26/07/2021.
//

import UIKit
import FirebaseAuth


class ResetPasswordController: UIViewController{
    @IBOutlet weak var resetPasswordTV: UITextView!
    
    
    
    
    
    @IBOutlet weak var forgotPasswordView: UIView!

    @IBOutlet weak var resetNowButton: UIButton!

    
    
    override func viewDidLoad() {
        
        
        forgotPasswordView.setShadow()
        forgotPasswordView.layer.cornerRadius = 40.0
        
        
        
       resetNowButton.layer.cornerRadius = resetNowButton.frame.height / 2
        
        
        
        resetPasswordTV.spellCheckingType = .no
        resetPasswordTV.autocorrectionType = . no
    }
    
    @IBAction func resetPassword(_ sender: Any) {
   
        
        guard let email = resetPasswordTV.text, !email.isEmpty else{
            
            DispatchQueue.main.async {
                self.showError(message: "Please provide a valid email address", dismiss: false, toLogin: false)            }
            
            
            // error with login
            
            print("loginn failed")
            return
        }
        
        
        
        
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
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
        self.dismiss(animated: true, completion: nil)

    }
    
    
    

    
    
    func showError(message: String, dismiss: Bool, toLogin: Bool) {
            
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        if dismiss {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                            
                
                if toLogin{
                    self.dismiss(animated: true, completion: nil)

                }

            }))
        }
        self.present(alert, animated: true, completion: nil)
   
    }

    
    
    static func showPopup(parentVC: UIViewController){
        
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordController") as? ResetPasswordController {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            
            //presenting the pop up viewController from the parent viewController
            parentVC.present(popupViewController, animated: true)
        }
    }
    
    
}
