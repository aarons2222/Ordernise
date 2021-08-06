//
//  ViewController.swift
//  Ordernise
//
//  Created by Aaron on 18/07/2021.
//

import UIKit
import FirebaseAuth
import Tabman
import Pageboy

class OrdersController: TabmanViewController {
  
    
    private var viewControllers: Array<UIViewController> = []

    override func viewDidLoad() {
        super.viewDidLoad()
                viewSetup()
    }

    
    
    
    override func viewWillDisappear(_ animated: Bool) {
    }
 
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.generateHaptics()
    }

    
    
    func viewSetup() {
      let currentOrdersVC = self.storyboard?.instantiateViewController(withIdentifier: "currentOrdersVC")
      let completedOrdersVC = self.storyboard?.instantiateViewController(withIdentifier: "completedOrdersVC")
      
      viewControllers.append(currentOrdersVC!)
      viewControllers.append(completedOrdersVC!)
      
      self.dataSource = self
      let bar = TMBar.ButtonBar()
        
        let tabBar = TMBar.TabBar()
        
        
        
      tabBar.layout.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    
        
        
      bar.backgroundView.style = .blur(style: .light)
      bar.backgroundColor = .white
      bar.layout.interButtonSpacing = 40
      bar.layout.transitionStyle = .snap
        bar.layout.contentMode = .fit
      bar.indicator.weight = .light
      bar.indicator.tintColor = UIColor(named: "CustomBlue")
      bar.buttons.customize { (button) in
        button.tintColor = .gray
        button.selectedTintColor = UIColor(named: "CustomBlue")
      }
      addBar(bar, dataSource: self, at: .top)
    }
  }




  extension OrdersController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
      scrollToPage(.at(index: 0), animated: true)
      let  item = TMBarItem(title: "")
      if (index == 0) {
        item.title = "Open"
    
      } else if (index == 1) {
        item.title = "Completed"
      }
      return item
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
      return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
      // 어떤 뷰
      return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
      return nil
    }
}

