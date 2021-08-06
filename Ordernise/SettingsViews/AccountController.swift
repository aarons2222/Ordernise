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
    
    @IBOutlet weak var businessLogo: UIButton!
    @IBOutlet weak var businessNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    
    var image:UIImage?=nil

    override func viewDidLoad() {
      

        
     
  
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.businessNameLabel.text = UserDefaults.standard.string(forKey: "businessName")
                self.emailLabel.text = UserDefaults.standard.string(forKey: "userEmail")
                self.nameLabel.text = UserDefaults.standard.string(forKey: "userName")
        self.currencyLabel.text = UserDefaults.standard.string(forKey: "userCurrency")
             
            
        
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
           // let downloadURL = storageRef.downloadURL(completion: <#(URL?, Error?) -> Void#>)
           //  print(downloadURL)
        })
    
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.image=(info[.originalImage] as! UIImage);
        businessLogo.setBackgroundImage(image, for: .normal)
        self.dismiss(animated: true, completion: nil)
        
        
    }
}
