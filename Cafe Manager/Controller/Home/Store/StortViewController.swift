//
//  StortViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit

class StortViewController: BaseViewController {

    var tabBar: UITabBarController?
    @IBOutlet weak var segTab: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeTabs" {
            guard let tabBar = segue.destination as? UITabBarController else {
                return
            }
            self.tabBar = tabBar
            self.tabBar?.tabBar.isHidden = true
        }
        
    }
    
    
    @IBAction func onSegmentedTabChangee(_ sender: UISegmentedControl) {
        self.tabBar?.selectedIndex = sender.selectedSegmentIndex
    }
    

}
