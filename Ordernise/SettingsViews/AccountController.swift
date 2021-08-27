//
//  AccountController.swift
//  Ordernise
//
//  Created by Aaron on 03/08/2021.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseStorage



class  AccountController:  UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let db = Firestore.firestore()

    @IBOutlet weak var accountInfoTable: UITableView!
    
    @IBOutlet weak var businessNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    
    
    
    

    
    var image:UIImage?=nil
    
    let imgName = "profilePic"
    
    let method = Auth.auth().currentUser?.providerID.description
    
    override func viewDidLoad() {
      
     
  
        setFields()
        
        
        
    }
    
    
    
    
    
    func setFields(){
        
        self.businessNameLabel.text = UserDefaults.standard.string(forKey: "businessName")
                self.emailLabel.text = UserDefaults.standard.string(forKey: "userEmail")
        self.currencyLabel.text = UserDefaults.standard.string(forKey: "userCurrency")

        
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
  
    }
    
    
    
    

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        let signin = UserDefaults.standard.string(forKey: "LoginMethod")

        
          if (signin == "APPLE"){

            if indexPath.section == 1 {
            
            return 0
                
           
        }
          }
        return tableView.rowHeight
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        
        
      
    
        
        if indexPath?.section != 1{
            
            
      
        if indexPath?.row == 2{
            
            //currency selected
        } else{
            
            // everything else
            
            let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell

          
            var editTitle: UILabel!
          
            editTitle = currentCell.textLabel
            
            
            let alertController = UIAlertController(title: "Edit \(editTitle.text!)", message: "", preferredStyle: .alert)
                    
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let textField: UITextField = alertController.textFields![0] as UITextField
                
               
            
                   

               self.updateUserInfo(field: editTitle.text!, value: textField.text)
                
                
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = currentCell.detailTextLabel!.text
            })
            
       
            self.present(alertController, animated: true, completion: nil)
            
            
            
        }
            
        }
        
    }
    
    func updateUserInfo(field: String?, value: String?){
        //set NSDefaults
      
        
        switch field {
        case "Business Name":
            UserDefaults.standard.set(value, forKey: "businessName")
        case "Your Name":
            UserDefaults.standard.set(value, forKey: "userName")
        case "Email Address":
            UserDefaults.standard.set(value, forKey: "userEmail")
        default:
            print("default")
        }
        
        
      
        
      
       
        
        
        
        //set textview
        setFields()
        
        //UPADTE FIREBASE
        
        
        
        let userID : String = (Auth.auth().currentUser?.uid)!
        

        
        
        
        db.collection("Users").document(userID).updateData([
            "email": UserDefaults.standard.string(forKey: "userEmail")!,
            "name": UserDefaults.standard.string(forKey: "userName")!,
            "business": UserDefaults.standard.string(forKey: "businessName")!,
            "currency": UserDefaults.standard.string(forKey: "userCurrency")!
      
                              ]) { err in
                                  if let err = err {
                                      print("Error writing document: \(err)")
                                  } else {
                                      print("Document successfully written!")
                                    
                                    
                                  }
                              }
        
    }
    
    
    
    
    
    
    
    @IBAction func upload(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func changeProfileLogo(_ sender: Any) {
  
        let storage = Storage.storage()
        var data = Data()
        data = (self.image?.pngData())!;
        let storageRef = storage.reference()
        print(storageRef)
        var imagenameurl="images/\(storageRef).png"
        //var imagenameurl="images/sec.png"
        

        
        let imageRef=storageRef.child(imagenameurl)
        imageRef.putData(data,metadata: nil,completion: { (metadata,error) in
            guard let metadata = metadata else{
                print(error!)
                return
            }
     
        })
        
    
    }
    
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.image=(info[.originalImage] as! UIImage);
     
        
        self.saveImage(imageName: imgName, image: image!)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    

}
