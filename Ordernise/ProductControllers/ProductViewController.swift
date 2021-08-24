//
//  NoteViewController.swift
//  Ordernise
//
//  Created by Aaron Strickland on 24/08/2021.
//

import UIKit

class ProductViewController: UIViewController {

 
    
    
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var productDesc: UITextView!
    
    public var product_Title: String = ""
    public var desc: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        productTitle.text = product_Title
        productDesc.text = desc
    }


}

