//
//  CompleteAccountController.swift
//  Ordernise
//
//  Created by Aaron on 02/08/2021.
//

import UIKit
import FirebaseAuth
import Firebase




class CompleteAccountController: UIViewController{
    
    let db = Firestore.firestore()

    
    @IBOutlet weak var yourName: UITextField!
    @IBOutlet weak var businessName: UITextField!
    @IBOutlet weak var currency: UITextField!
    
    @IBOutlet weak var welcomeMessage: UILabel!
    
    @IBAction func completeAccount(_ sender: Any) {
        
        
        if yourName.text != "" && businessName.text != "" && currency.text != ""{
            
            let userID : String = (Auth.auth().currentUser?.uid)!
            let email : String = (Auth.auth().currentUser?.email)!
      
            self.db.collection("Users").document(userID).setData([
                "email": email,
                "name": yourName.text! as String,
                "business": businessName.text! as String,
                "currency": currency.text! as String
          
                                  ]) { err in
                                      if let err = err {
                                          print("Error writing document: \(err)")
                                      } else {
                                          print("Document successfully written!")
                                        UserDefaults.standard.set(true, forKey: "isAccountComplete")
                                        
                                        
                                        DispatchQueue.main.async {
                                
                                            
                                
                                            self.performSegue(withIdentifier: "accountIsComplete", sender: nil)

                                            
                                        }

                                      }
                                  }
          
            
            
            
          
            
        }else{
            
            showError(message: "Please complete all fields", dismiss: true)

            yourName.text = ""
            businessName.text = ""
            currency.text = ""
        
    
        }
    }
    
    
    
    override func viewDidLoad() {
    
        welcomeMessage.font = welcomeMessage.font.withSize(22)
        
        let email : String = (Auth.auth().currentUser?.email)!

            
        welcomeMessage.text = "Hi, \(email)"
        
        
        
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
