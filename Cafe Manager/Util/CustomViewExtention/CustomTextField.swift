//
//  CustomTextField.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation


import UIKit

class CustomTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

}

extension CustomTextField {
    @IBInspectable var doneAccessory: Bool{
            get{
                return self.doneAccessory
            }
            set (hasDone) {
                if hasDone{
                    addDoneButtonOnKeyboard()
                }
            }
        }
        
        func addDoneButtonOnKeyboard()
        {
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
            
            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            
            self.inputAccessoryView = doneToolbar
        }
        
        @objc func doneButtonAction()
        {
            self.resignFirstResponder()
        }
}
