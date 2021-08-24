//
//  EntryViewController.swift
//  Ordernise
//
//  Created by Aaron Strickland on 24/08/2021.
//


import UIKit

class EntryViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var pricefield: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    public var completion: ((String, String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "CustomBlue")
    }

    @objc func didTapSave() {
        if let text = titleField.text, !text.isEmpty, !descriptionField.text.isEmpty  {
            completion?(text, descriptionField.text, pricefield.text!)
        }
    }


}
