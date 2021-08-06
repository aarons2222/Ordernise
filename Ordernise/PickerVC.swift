//
//  PickerVC.swift
//  Ordernise
//
//  Created by Aaron on 06/08/2021.
//

import UIKit
import CountryPicker

class PickerVC: UIViewController {

    @IBOutlet weak var storyboardPickerView: CountryPickerView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var storyboardLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show country picker view on tap TextField.
        setupPickerViewForTextField()
        
        // Configure picker with help of storyboard.
        setupStoryboardPickerViewCallback()
        
    }
    
    private func setupPickerViewForTextField() {
        
        let picketView = CountryPickerView.loadPickerView { [weak self] (country) in
            
            guard let self = self,
                let digitCountrycode = country.digitCountrycode else {
                return
            }
            let text = "\(digitCountrycode) \(country.countryCode)"
            self.textField.text = text
        }
        
        // Set pick list menually.
        picketView.setPickList(codes: "AQ", "IL", "AF", "AL", "DZ", "IN")
        textField.inputView = picketView
        
        let toolBar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        toolBar.barStyle = .default
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        toolBar.items = [doneButton]
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonTapped() {
        self.textField.resignFirstResponder()
    }
    
    private func setupStoryboardPickerViewCallback() {
        storyboardPickerView.onSelectCountry { [weak self] (country) in
            guard let self = self,
                let digitCountrycode = country.digitCountrycode else {
                return
            }
            let text = "\(digitCountrycode) \(country.countryCode)"
            self.storyboardLabel.text = text
        }
    }
}
