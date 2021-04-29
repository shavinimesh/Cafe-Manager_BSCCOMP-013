//
//  ProfileViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import UIKit

class ProfileViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func OnSignOutPressed(_ sender: UIButton) {
        
            displayActionSheet(title: "Sign Out", message: "Are You sure You Want To Sign Out From The Application ?", positiveTitle: "Sign out", negativeTitle: "Cancel", positiveHandler: {
                action in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    SessionManager.clearUserSession()
                    self.performSegue(withIdentifier: "profileToSplashScreen", sender: nil)
                    
                }
            }, negativeHandler: {
                action in
            })
        }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
