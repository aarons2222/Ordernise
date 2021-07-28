//
//  RegistrationController.swift
//  Ordernise
//
//  Created by Aaron on 25/07/2021.
//

import UIKit
import FirebaseAuth

class RegistrationController: UIViewController {

    @IBOutlet weak var registrationEmail: UITextField!
    
    @IBOutlet weak var registrationPassword: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
    }

    
    
    
    @IBAction func btnRegister(_ sender: Any) {
        

        
        guard let email = registrationEmail.text, !email.isEmpty,
              let password = registrationPassword.text, !password.isEmpty else{
            
            
            
            // error with login
            
            print("loginn failed")
            return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
            

            
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
                        self?.performSegue(withIdentifier: "registeredSeque", sender: nil)

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

