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
    @IBOutlet var productPrice: UILabel!
    
    public var product_Title: String = ""
    public var product_Desc: String = ""
    public var product_Price: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        productTitle.text = product_Title
        productDesc.text = product_Desc
        productPrice.text = product_Price
    }


}

