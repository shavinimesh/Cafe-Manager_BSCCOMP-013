//
//  BaseViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation
import UIKit

class PopupAlerts {
    
    var alert: UIAlertController!
    var networkLostAlert: UIAlertController?
    //Class instance
    static var instance = PopupAlerts()
    
    //Make Singleton
    fileprivate init() {}
    
    //Create an alert with providing title and body
    func createAlert(title: String, message : String) -> Self {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return self
    }
    
    //Add an action button to the alertview
    func addAction(title: String, handler: @escaping (UIAlertAction) -> Void) -> Self {
        self.alert.addAction(UIAlertAction(title: title, style: .default, handler: handler))
        return self
    }
    
    //Add an default action button (cancel) to the alertview
    func addDefaultAction(title: String) -> Self {
        self.alert.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        return self
    }
    
    //Returns and display the alert
    func displayAlert(vc: UIViewController) {
        DispatchQueue.main.async {
            if let alert = self.alert {
                guard (vc.presentedViewController as? UIAlertController) != nil else {
                    vc.present(alert, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    func displayNetworkLossAlert(vc: UIViewController) {
        guard networkLostAlert != nil else {
            self.networkLostAlert = UIAlertController(title: FieldErrorCaptions.noConnectionTitle, message: FieldErrorCaptions.noConnectionMessage, preferredStyle: .alert)
            self.networkLostAlert?.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            vc.present(networkLostAlert!, animated: true, completion: nil)
            return
        }
        
        DispatchQueue.main.async {
            if let networkLostAlert = self.networkLostAlert {
                guard (vc.presentedViewController as? UIAlertController) != nil else {
                    vc.present(networkLostAlert, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    func displayNetworkLossAlert(vc: UIViewController, actionTitle: String, actionHandler: @escaping (UIAlertAction) -> Void) {
        guard networkLostAlert != nil else {
            self.networkLostAlert = UIAlertController(title: FieldErrorCaptions.noConnectionTitle, message: FieldErrorCaptions.noConnectionMessage, preferredStyle: .alert)
            self.networkLostAlert?.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.networkLostAlert?.addAction(UIAlertAction(title: actionTitle, style: .default, handler: actionHandler))
            vc.present(networkLostAlert!, animated: true, completion: nil)
            return
        }
        DispatchQueue.main.async {
            if let networkLostAlert = self.networkLostAlert {
                guard (vc.presentedViewController as? UIAlertController) != nil else {
                    vc.present(networkLostAlert, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    

}
