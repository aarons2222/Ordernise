//
//  ChangeEmailController.swift
//  Ordernise
//
//  Created by Aaron on 08/08/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class ChangeEmailController: UIViewController{
    

    @IBOutlet weak var newEmailField: FloatingTextField!
    @IBOutlet weak var confirmNewEmailField: FloatingTextField!
    @IBOutlet weak var passwordField: FloatingTextField!
    @IBOutlet weak var changeEmailButton: UIButton!
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super .viewDidLoad()
        
        self.title = "Update Email Address"
        
    }
    
    
    
    
    @IBAction func emailUpdateButton(_ sender: Any) {
        
        //check emails are valid
        
    
        if InputValidation.validateEmailAddress(email: newEmailField.text!){
            
            // check if both emails match
            print("email is valid")
            
            if newEmailField.text! == confirmNewEmailField.text{
                
                print("emails match")
                //emails match now authenticaate with firebase 
                
                
                if passwordField.text!.count < 8{
                    print("password is too short")
                    self.showAlert(title: "Password too short", message: "Please provide a password that is longer than seven characters", toSettings: false)
                    
                }else{
                    
                    //all requirements met authenticate user
                    
                    print("password is coorecct length authenticating")
                    
                    let user = Auth.auth().currentUser

                    
                    let email = Auth.auth().currentUser?.email
                    
                    Auth.auth().signIn(withEmail: email!, password: passwordField.text!) { [self] (user, error) in
                        if error == nil {
         
                            
                            
                            Auth.auth().currentUser?.updateEmail(to: self.confirmNewEmailField.text!) { error in
                                if error != nil {
                                    // An error happened
                                    self.showAlert(title: "Something went wrong", message: "Please try again", toSettings: false)
                                    
                                } else {
                                   // Email updated.
                                    self.showAlert(title: "Success", message: "Your email address has been updated", toSettings: true)
                                    
                                    
                                    
                                    //set email to defaults
                                    UserDefaults.standard.set(self.confirmNewEmailField.text!, forKey: "userEmail")
                                    
                                    
                                    
                                    let userID : String = (Auth.auth().currentUser?.uid)!
                                    

                                    
                                    
                                    
                                    db.collection("Users").document(userID).updateData([
                                        "email": self.confirmNewEmailField.text!,
                                      
                                  
                                                          ]) { err in
                                                              if let err = err {
                                                                  print("Error writing document: \(err)")
                                                              } else {
                                                                  print("Document successfully written!")
                                                                
                                                                
                                                              }
                                                          }
                                    
                              
                                   }
                                
                        }
                            
                          
                            
                            
                            
                        } else {
                          //handle error
                      // failed to re authenticate
                            self.newEmailField.text = ""
                            self.confirmNewEmailField.text = ""
                            self.passwordField.text = ""
                            print("AUTHERROR \(error)")
                            
                            self.showAlert(title: "Something went wrong", message: "Please try again", toSettings: false)
                        }
                      }
                    
                    
                    
                    
                    
                    
                }
                
                
            } else{
                //emails do not match
                print("Emails do not match")
                
                self.showAlert(title: "Error", message: "The provided email address do not match", toSettings: false)
                
            }

            
            
        } else{
            
            // invalid email entered show alert
            self.showAlert(title: "Error", message: "Please provide a valid email address", toSettings: false)
            
            
            
        }
        
        
    
        
        //update password
        
        // update shared preffs (NSDefaults)
        
    }
    
    
}
