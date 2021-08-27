//
//  EntryViewController.swift
//  Ordernise
//
//  Created by Aaron Strickland on 24/08/2021.
//


import UIKit

class EntryViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
   @IBOutlet var descriptionField: UITextField!
    @IBOutlet var priceField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var productEntryView: UIView!
    
    public var completion: ((String, String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        UIView.setAnimationsEnabled(false)
        
        productEntryView.setShadow()
        productEntryView.layer.cornerRadius = 40.0
        
        
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        self.navigationItem.setHidesBackButton(true, animated: true)

        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "CustomBlue")
     
     
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.performSegue(withIdentifier: "back", sender: nil)
    }
    
    
    
    
    @IBAction func didTapSave(_ sender: Any) {
        if let text = titleField.text, !text.isEmpty,!priceField.text!.isEmpty, !descriptionField.text!.isEmpty {
            completion?(text, descriptionField.text!, priceField.text!)
        }
    }
    
  
    static func showPopup(parentVC: UIViewController){
        
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EntryViewController") as? EntryViewController {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            
            //presenting the pop up viewController from the parent viewController
            parentVC.present(popupViewController, animated: true)
        }
    }
    


}
