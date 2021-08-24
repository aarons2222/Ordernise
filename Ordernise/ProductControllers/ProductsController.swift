//
//  ProductsController.swift
//  Ordernise
//
//  Created by Aaron on 28/07/2021.
//

import UIKit

class ProductsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var label: UILabel!
    


    var models: [(title: String, note: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        title = "Notes"
      
        
      
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(self.didTapNewNote))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "CustomBlue")
        self.title = "Products"
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        self.generateHaptics()

    }
 
    
    @IBAction func didTapNewNote() {
        guard let vc = storyboard?.instantiateViewController(identifier: "new") as? EntryViewController else {
            return
        }
        vc.title = "New Product"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { noteTitle, note, price in
            self.navigationController?.popToRootViewController(animated: true)
            self.models.append((title: noteTitle, note: note))
            self.label.isHidden = true
            self.table.isHidden = false

            self.table.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MyCustomCell = table.dequeueReusableCell(withIdentifier: "cell") as! MyCustomCell
        
        cell.myView.backgroundColor = UIColor.cyan
   
   

        cell.productTitle.text = models[indexPath.row].title
        cell.productDescription.text = models[indexPath.row].note
        
     

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = models[indexPath.row]

        // Show note controller
        guard let vc = storyboard?.instantiateViewController(identifier: "product") as? ProductViewController else {
            return
        }
        vc.title = "Product"
        
        
        vc.productTitle.text = model.title
        vc.productDesc.text = model.note
        
        
        navigationController?.pushViewController(vc, animated: true)
    }

}

