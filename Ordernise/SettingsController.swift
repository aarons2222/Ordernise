//
//  SettingsController.swift
//  Ordernise
//
//  Created by Aaron on 28/07/2021.
//

import UIKit
import FirebaseAuth

class SettingsController: UITableViewController
{
    

    
    override func viewDidLoad() {
        
      
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
        
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 1 {
            
            if (indexPath.row == 1) {
                
            }
        } else if indexPath.section == 2 {
            if (indexPath.row == 1) {
                
            }
        }else if indexPath.section == 3 {
            if (indexPath.row == 1) {
                print("section 3 row 1")
            }
        }else if indexPath.section == 4 {
            if (indexPath.row == 0) {
                
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
    }
    
    
    
}
        

        
        
        
        
    

    
    

