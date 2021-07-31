//
//  SettingsController.swift
//  Ordernise
//
//  Created by Aaron on 28/07/2021.
//

import UIKit
import FirebaseAuth

class SettingsController: UIViewController{
    
    weak var myVC : UIViewController?

    
    override func viewDidLoad() {
        
    }
    @IBAction func signOutUser(_ sender: Any) {
        let myActionSheet =  UIAlertController(title: "Are you sure you want to sign out?", message: "You will no longer have access to the apps features until you sign in", preferredStyle: UIAlertController.Style.actionSheet)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        myActionSheet.addAction(UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.default, handler: { (ACTION :UIAlertAction!)in
            
               do { try Auth.auth().signOut() }
                 catch { print("already logged out") }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                    self.present(newViewController, animated: true, completion: nil)
              }))
      
        self.present(myActionSheet, animated: true, completion: nil)
        
    }
    
    
}
