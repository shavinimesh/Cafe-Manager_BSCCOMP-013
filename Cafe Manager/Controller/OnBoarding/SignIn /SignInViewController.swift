//
//  SignInViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import UIKit

class SignInViewController: BaseViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkMonitor.delegate = self
        firebaseOP.delegate = self
        setTextDelegates()
//        btnSignIn.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        networkMonitor.delegate = self
    }

    @IBAction func onSignInClick(_ sender: UIButton) {
        if !InputFieldValidator.isValidEmail(txtEmail.text ?? "") {
            txtEmail.clearText()
            txtEmail.displayInlineError(errorString: InputErrorCaptions.invalidEmailAddress)
            return
        }
        
        if !InputFieldValidator.isValidPassword(pass: txtPassword.text ?? "", minLength: 6, maxLength: 20){
            txtPassword.clearText()
            txtPassword.displayInlineError(errorString: InputErrorCaptions.invalidPassword)
            return
        }
        
        if !networkMonitor.isReachable {
            self.displayErrorMessage(message: FieldErrorCaptions.noConnectionTitle)
            return
        }
        
        displayProgress()
        self.firebaseOP.signInUser(email: txtEmail.text ?? "", password: txtPassword.text ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func setTextDelegates(){
        txtEmail.delegate = self
        txtPassword.delegate = self
    }
}

extension SignInViewController: FirebaseActions {
    func onUserNotRegistered(error: String) {
        dismissProgress()
        displayErrorMessage(message: error)
    }
    func onUserSignInSuccess(user: User?) {
        dismissProgress()
        if let user = user {
            self.performSegue(withIdentifier: "signInToHome", sender: nil)
            SessionManager.saveUserSession(user)
        } else {
            displayErrorMessage(message: FieldErrorCaptions.generalizedError)
        }
    }
    func onUserSignInFailedWithError(error: Error) {
        dismissProgress()
        displayErrorMessage(message: error.localizedDescription)
    }
    func onUserSignInFailedWithError(error: String) {
        dismissProgress()
        displayErrorMessage(message: error)
    }
}

