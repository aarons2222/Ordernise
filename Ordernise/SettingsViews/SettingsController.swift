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
    @IBOutlet weak var appearanceSegmentedControl: UISegmentedControl!


    
    override func viewDidLoad() {
        
        setAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.generateHaptics()
    }
    
    
    func setAppearance() {
        
        /// makes sure this view controller's appearance is synced with the user default value set by the segmented control
        let defaults = UserDefaults.standard
        let appearanceSelection = defaults.integer(forKey: "appearanceSelection")
        
        if appearanceSelection == 0 {
            overrideUserInterfaceStyle = .unspecified
        } else if appearanceSelection == 1 {
            overrideUserInterfaceStyle = .light
        } else {
            overrideUserInterfaceStyle = .dark
        }
    }
    
    @IBAction func appearanceValueChanged(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        if appearanceSegmentedControl.selectedSegmentIndex == 0 {
            overrideUserInterfaceStyle = .unspecified
            defaults.setValue(0, forKey: "appearanceSelection")
        } else if appearanceSegmentedControl.selectedSegmentIndex == 1 {
            overrideUserInterfaceStyle = .light
            defaults.setValue(1, forKey: "appearanceSelection")
        } else if appearanceSegmentedControl.selectedSegmentIndex == 2 {
            overrideUserInterfaceStyle = .dark
            defaults.setValue(2, forKey: "appearanceSelection")
        } else {
            print("selection error")
        }
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
        
    }
 
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 4{
            return 50
        }else{
            return 10
        }
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0 {
            
            if (indexPath.row == 0) {
                //my account
                print("account")
            }else if  (indexPath.row == 1) {
                // change password
                
                print("password")
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
                myActionSheet.addAction(UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.destructive, handler: { (ACTION :UIAlertAction!)in
                    
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
        

        
        
        
        
    

    
    

