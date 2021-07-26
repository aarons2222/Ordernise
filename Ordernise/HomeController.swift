//
//  ViewController.swift
//  Ordernise
//
//  Created by Aaron on 18/07/2021.
//

import UIKit
import FirebaseAuth

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
 
        
        
        
        
        if Auth.auth().currentUser?.uid != nil {

           //user is logged in

            }else{
             //user is not logged in

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "notLoggedIn", sender: nil)

                }
                
            }
    }


    @IBAction func logOutUser(_ sender: Any) {
        
        do { try Auth.auth().signOut() }
          catch { print("already logged out") }
        self.performSegue(withIdentifier: "logOutSegue", sender: nil)

    }
}

