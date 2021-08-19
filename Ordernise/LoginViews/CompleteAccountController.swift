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


    @IBOutlet weak var currency: UITextField!

    @IBOutlet weak var buinessName: UITextField!
    
    @IBOutlet weak var welcomeMessage: UILabel!
    
    @IBOutlet weak var completeAccount: UIButton!
    
    @IBOutlet weak var completeView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let email : String = (Auth.auth().currentUser?.email)!
        
        
        

        completeView.setShadow()
        completeView.layer.cornerRadius = 40.0
        
        completeAccount.layer.cornerRadius = completeAccount.frame.height / 2
    


        
    }
    
    
    
    @IBAction func completeAccount(_ sender: Any) {
        
        
        if currency.text != ""{
            
            let userID : String = (Auth.auth().currentUser?.uid)!
            let email : String = (Auth.auth().currentUser?.email)!
            
            
            db.collection("Users").document(userID).updateData([
              
                "businessName": buinessName.text!,
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

 
            currency.text = ""
        
    
        }
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
