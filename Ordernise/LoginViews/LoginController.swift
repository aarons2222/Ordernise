//
//  LoginController.swift
//  Ordernise
//
//  Created by Aaron on 25/07/2021.
//

import UIKit
import FirebaseAuth
import Firebase
import CryptoKit
import FirebaseCore
import AuthenticationServices
import GoogleSignIn


class LoginController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var loginEmail: FloatingTextField!
    @IBOutlet weak var loginPassword: FloatingTextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var loginView: UIView!
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        loginView.setShadow()
        loginView.layer.cornerRadius = 40.0
        
        
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2

        
        
        
 
            
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil && Auth.auth().currentUser!.isEmailVerified {
            print("USER LOGGED IN")
            
            if !UserDefaults.standard.bool(forKey: "isAccountComplete")

            {
                
                DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toCompleteAccount", sender: nil)
                }
                
            }else{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toHome", sender: nil)
            }
            }
         }
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
                        
                        
                        if result?.user.isEmailVerified == true{

                   
                       
                           
                            // check if user has completed account
                            if !UserDefaults.standard.bool(forKey: "isAccountComplete")

                            {
                                
                                
                                self?.performSegue(withIdentifier: "toCompleteAccount", sender: nil)

                                
                            }else{
                                
                          // login success
                                    
                                    self?.performSegue(withIdentifier: "toHome", sender: nil)
                                UserDefaults.standard.set("EMAIL", forKey: "LoginMethod")

                            }
                            
                  
                        } else{
                            // user is not verified
                            
                            let alert = UIAlertController(title: "Account not verified", message: "Please check your inbox for a verification email", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                                
                            }))
                            
                            
                            alert.addAction(UIAlertAction(title: "Resend Confirmation", style: .default, handler: { action in
                                
                                
                                
                                Auth.auth().currentUser?.sendEmailVerification { error in
                                  // ...
                                }
                            }))
                            
                            
                            self!.present(alert, animated: true, completion: nil)
                        }
                        
                        
                        
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
    
    
    var fromLogin = true

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHome" {
          fromLogin = false
        }
    }
    

    
    
    
    
    
}


