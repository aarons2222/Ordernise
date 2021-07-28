//
//  ViewController.swift
//  Ordernise
//
//  Created by Aaron on 18/07/2021.
//

import UIKit
import FirebaseAuth

class OrdersController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        
        if Auth.auth().currentUser?.uid != nil {

           //user is logged in

            }else{
             //user is not logged in

                DispatchQueue.main.async {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                            self.present(newViewController, animated: true, completion: nil)
                }
                
            }
    }


  
}

