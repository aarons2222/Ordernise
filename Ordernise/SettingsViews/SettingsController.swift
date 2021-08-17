//
//  SettingsController.swift
//  Ordernise
//
//  Created by Aaron on 28/07/2021.
//

import UIKit
import FirebaseAuth
import Firebase


import MessageUI
import StoreKit
import SafariServices

class SettingsController: UITableViewController
{
    @IBOutlet weak var appearanceSegmentedControl: UISegmentedControl!
    let supportEmail = "support@ordernise.com"

    

    
    override func viewDidLoad() {
        
        
        setAppearance()
        
        let db = Firestore.firestore()
      
       let user = Auth.auth().currentUser?.uid
       
       let docRef = db.collection("Users").document(user!)

       docRef.getDocument { [self] (document, error) in
           if let document = document, document.exists {
            
            
            //grab details from forebase
              UserDefaults.standard.set(document.get("business") as? String, forKey: "businessName")
              UserDefaults.standard.set(document.get("email") as? String, forKey: "userEmail")
              UserDefaults.standard.set(document.get("name") as? String, forKey: "userName")
              UserDefaults.standard.set(document.get("currency") as? String, forKey: "userCurrency")
               
           
              // let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
             //  print("Document data: \(dataDescription)")
           } else {
               print("Document does not exist")
           }
       }
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
            if (indexPath.row == 0) {
       
                
                
            }else if (indexPath.row == 1) {
               

                let shareSheet =  UIActivityViewController(activityItems: [ShareSheetStrings()], applicationActivities: .none)
                        self.present(shareSheet, animated: true, completion: nil)

            }
        }else if indexPath.section == 3 {
            if (indexPath.row == 0) {
                composeShareEmail()
            }
        }else if indexPath.section == 4 {
            if (indexPath.row == 0) {
                
                let myActionSheet =  UIAlertController(title: "Are you sure you want to sign out?", message: "You will no longer have access to the apps features until you sign in", preferredStyle: UIAlertController.Style.actionSheet)
                myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                myActionSheet.addAction(UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.destructive, handler: { (ACTION :UIAlertAction!)in
                    
                       do { try Auth.auth().signOut() }
                         catch { print("already logged out") }
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeController") as! WelcomeController
                            self.present(newViewController, animated: true, completion: nil)
                    UserDefaults.standard.set("", forKey: "LoginMethod")

                      }))
              
                self.present(myActionSheet, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
}
        

        
        
        
        
extension SettingsController: MFMailComposeViewControllerDelegate {
    
    func composeShareEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let messageBody: String
        let deviceModelName = UIDevice.modelName
        let iOSVersion = UIDevice.current.systemVersion
        let topDivider = "------- Developer Info -------"
        let divider = "------------------------------"
        
        if let appVersion = UIApplication.appVersion {
            
            messageBody =  "\n\n\n\n\(topDivider)\nApp version: \(appVersion)\nDevice model: \(deviceModelName)\niOS version: \(iOSVersion)\n\(divider)"
        } else {
            messageBody = "\n\n\n\n\(topDivider)\nDevice model: \(deviceModelName)\niOS version: \(iOSVersion)\n\(divider)"
        }
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([supportEmail])
        mailComposerVC.setSubject("Your Ordernise Feedback")
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        return mailComposerVC
    }
    
    /// This alert gets shown if the device is a simulator, doesn't have Apple mail set up, or if mail in not available due to connectivity issues.
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send email. Please check email configuration and internet connection and try again.", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

    
    

