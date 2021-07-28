//
//  LoginController.swift
//  Ordernise
//
//  Created by Aaron on 25/07/2021.
//

import UIKit
import FirebaseAuth



class LoginController: UIViewController {
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
    }
    
    
    
    @IBAction func btnLogin(_ sender: Any) {
        
        
        guard let email = loginEmail.text, !email.isEmpty,
              let password = loginPassword.text, !password.isEmpty else{
            self.showError(message: "Please enter a password", dismiss: true)

            print("loginn failed")
            return
        }

        
        
        
       

        if(loginPassword.text!.count < 7) {
            
            DispatchQueue.main.async {
                
                self.loginPassword.text = ""
                self.showError(message: "Password too short", dismiss: true)
            }
            
            print("logionn failed")
            return
        }
       
        
        
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self]result, error in
            
            if error != nil {

                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    print("Error \(errCode)")

                             switch errCode {
                             case .invalidEmail:
                                DispatchQueue.main.async {
                                    print("Email does not exist")
                                    self!.showError(message: "Email does not exist", dismiss: true)
                                }
                             case .userNotFound:
                                DispatchQueue.main.async {
                                    print("User does not exist")
                                    self!.showError(message: "We could not find an account with those details", dismiss: true)
                                }
                                 case .wrongPassword:
                                    DispatchQueue.main.async {
                                        self!.showError(message: "Oops! those details are incrrect", dismiss: true)
                                    }
                                 default:
                                     print("Create User Error: \(error!)")
                             }
                         }

                     } else {
                        self?.performSegue(withIdentifier: "loggedInSegue", sender: nil)
                        
                     }
            
            
        

        })
    }
    
    

    
       func showError(message: String, dismiss: Bool) {
               
           let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
           if dismiss {
               alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
               }))
           }
           self.present(alert, animated: true, completion: nil)
      
       }
       


}

