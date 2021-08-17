//
//  RegistrationController.swift
//  Ordernise
//
//  Created by Aaron on 25/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

import Firebase


class RegistrationController: UIViewController {

    @IBOutlet weak var businessName: UITextField!
    @IBOutlet weak var registrationEmail: UITextField!
    @IBOutlet weak var registrationPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var btnLogin: UIButton!
        
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

       
        
        
        registrationView.setShadow()
        registrationView.layer.cornerRadius = 40.0
        
        
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2
        
    }

    
    @IBAction func btnRegister(_ sender: Any) {
        

        
        guard let email = registrationEmail.text, !email.isEmpty,
              let password = registrationPassword.text, !password.isEmpty else{
            
            
            
            // error with login
            
            print("loginn failed")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
            

        
            print("REGISTRATIOPN in")
            
            
            
            if error != nil {

                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    print("Error \(errCode)")

                             switch errCode {
                             case .emailAlreadyInUse:
                                DispatchQueue.main.async {
                                    print("Email alread exists")
                                    self!.showError(message: "That account already exists, please login", dismiss: true, toLogin: true)
                                }

                             case .invalidEmail:
                                DispatchQueue.main.async {
                                    print("User does not exist")
                                    self!.showError(message: "Please provide a valid email address", dismiss: true, toLogin: false)
                                }
                                
                             case .weakPassword:
                                DispatchQueue.main.async {
                                    print("User does not exist")
                                    self!.showError(message: "Please provide a stronger password", dismiss: true, toLogin: false)
                                }
                               
                                 default:
                                     print("Create User Error: \(error!)")
                             }
                         }

                     } else {
                        
                        // registered successfully
                        
                        Auth.auth().currentUser?.sendEmailVerification { error in
                     
                            if error != nil {
                                
                                // error sengin vrification email
                                print("TAG REGISTRATION \(String(describing: error))")
                            }else{
                                
                          //Bool

                                print("TAG REGISTRATION SUCCESS")
                                let alert = UIAlertController(title: "Thank you for registering", message: "A verification email has been to \(email)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                    
                                    
                                    
                                    if action.style == .default{
                                        DispatchQueue.main.async {

                                            
                                                          self?.performSegue(withIdentifier: "toLogin", sender: nil)
                                            
                                        }
                                    }
                                    
                                }))
                                self!.present(alert, animated: true, completion: nil)
                                
                            }
                        }
                        
                        

                        
                        
                        
                        
                        
                        
//                        let userID = result?.user.uid
//
//
//                        self?.db.collection("Users").document(userID!).setData([
//                            "email": email,
//                            "name": "Aaron Strickland",
//                            "business": "Knot in the shops",
//                            "currency": "GBP"
//
//                        ]) { err in
//                            if let err = err {
//                                print("Error writing document: \(err)")
//                            } else {
//                                print("Document successfully written!")
//                            }
//                        }
//
//                        self?.performSegue(withIdentifier: "registeredSeque", sender: nil)

                     }
            
            
        })
        
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

