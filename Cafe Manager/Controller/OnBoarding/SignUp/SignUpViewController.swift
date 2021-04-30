//
//  SignUpViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import UIKit

class SignUpViewController: BaseViewController {
    
//    @IBOutlet weak var txtName: UITextField!
//    @IBOutlet weak var txtEmail: UITextField!
//    @IBOutlet weak var txtPhoneNo: UITextField!
//    @IBOutlet weak var txtPassword: UITextField!
//    @IBOutlet weak var txtReenterPassword: UITextField!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtReenterPassword: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkMonitor.delegate = self
        firebaseOP.delegate = self
        setTextDelegates()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        networkMonitor.delegate = self
    }
    
    @IBAction func onSignInClicked(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSignUpClicked(_ sender: Any) {
        if !InputFieldValidator.isValidName(txtName.text ?? "") {
            txtName.clearText()
            txtName.displayInlineError(errorString: InputErrorCaptions.invalidName)
            return
        }
        
        if !InputFieldValidator.isValidEmail(txtEmail.text ?? "") {
            txtEmail.clearText()
            txtEmail.displayInlineError(errorString: InputErrorCaptions.invalidEmailAddress)
            return
        }
        
        if !InputFieldValidator.isValidMobileNo(txtPhoneNo.text ?? "") {
            txtPhoneNo.clearText()
            txtPhoneNo.displayInlineError(errorString: InputErrorCaptions.invalidPhoneNo)
            return
        }
        
        if !InputFieldValidator.isValidPassword(pass: txtPassword.text ?? "", minLength: 6, maxLength: 20){
            txtPassword.clearText()
            txtPassword.displayInlineError(errorString: InputErrorCaptions.invalidPassword)
            return
        }
        
        if !InputFieldValidator.isValidPassword(pass: txtReenterPassword.text ?? "", minLength: 6, maxLength: 20){
            txtReenterPassword.clearText()
            txtReenterPassword.displayInlineError(errorString: InputErrorCaptions.invalidPassword)
            return
        }
        
        if txtPassword.text ?? " " != txtReenterPassword.text ?? "" {
            txtPassword.clearText()
            txtReenterPassword.clearText()
            txtReenterPassword.displayInlineError(errorString: InputErrorCaptions.passwordNotMatched)
            txtPassword.displayInlineError(errorString: InputErrorCaptions.passwordNotMatched)
            return
        }
        
        if !networkMonitor.isReachable {
            self.displayErrorMessage(message: FieldErrorCaptions.noConnectionTitle)
            return
        }
        
        displayProgress()
        self.firebaseOP.registerUser(user: User(_id: "",
                                                userName: txtName.text!,
                                                email: txtEmail.text!,
                                                phoneNo: txtPhoneNo.text!,
                                                password: txtPassword.text!, imageRes: ""))
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

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func setTextDelegates() {
        txtName.delegate = self
        txtEmail.delegate = self
        txtPhoneNo.delegate = self
        txtPassword.delegate = self
        txtReenterPassword.delegate = self
    }
}

extension SignUpViewController : FirebaseActions {
    func onConnectionLost() {
        refreshControl.endRefreshing()
        dismissProgress()
        displayWarningMessage(message: "Please check internet connection")
    }
    
    func isSignUpSuccessful(user: User?) {
        dismissProgress()
        if let user = user {
            displaySuccessMessage(message: "Regisration Successful!", completion: {
                SessionManager.saveUserSession(user)
                self.performSegue(withIdentifier: "signInToHome", sender: nil)
            })
        } else {
            displayErrorMessage(message: FieldErrorCaptions.generalizedError)
        }
    }
    func isSignUpFailedWithError(error: Error) {
        dismissProgress()
        displayErrorMessage(message: error.localizedDescription)
    }
    func isSignUpFailedWithError(error: String) {
        dismissProgress()
        displayErrorMessage(message: error)
    }
    func isExisitingUser(error: String) {
        dismissProgress()
        displayErrorMessage(message: error)
    }
}
