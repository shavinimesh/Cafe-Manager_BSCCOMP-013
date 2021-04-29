//
//  InputFieldValidator.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation

class InputFieldValidator {
    
    //MARK: - Regular Expressions

    static let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let nameRegEx = "[A-Za-z ]{2,100}"
    static let NICRegEx = "^([0-9]{9}[x|X|v|V]|[0-9]{12})$"
    static let mobileRegex = "^(07)(0|1|2|5|6|7|8)[\\d]{7}$"
    static let accountNoRegex = "[0-9]{5,30}"
    static let bankDetailsRegex = "[A-Za-z ]{2,100}"
//    static let mobileRegex = "^(0)?(?:7(0|1|2|5|6|7|8)\\d)\\d{6}$"
    
    //Validate the Email address with Regex
    static func isValidEmail(_ email: String) -> Bool {
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //Validate the Name of a person with Regex
    static func isValidName(_ name: String) -> Bool{
        let compRegex = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return compRegex.evaluate(with: name)
    }
    
    //Validate the NIC no. with Regex
    static func isValidNIC(_ nic: String) -> Bool {
        let NicPred = NSPredicate(format:"SELF MATCHES %@", NICRegEx)
        return NicPred.evaluate(with: nic)
    }
    
    //Validates the passwords and checks it meets the requirements [MIN_LENGTH, MAX_LENGTH]
    static func isValidPassword(pass: String, minLength: Int, maxLength: Int) -> Bool {
        return pass.count >= minLength && pass.count <= maxLength
    }
    
    //Validates the mobile no
    static func isValidMobileNo(_ mobileNo: String) -> Bool{
        let mobPred = NSPredicate(format:"SELF MATCHES %@", mobileRegex)
        return mobPred.evaluate(with: mobileNo)
    }
    
    //Validates the bank account no
    static func isValidAccountNo(_ accountNo: String) -> Bool{
        let accPred = NSPredicate(format:"SELF MATCHES %@", accountNoRegex)
        return accPred.evaluate(with: accountNo)
    }
    
    //Validates the bank account no
    static func isvalidBankDetails(_ bankInfo: String) -> Bool{
        let bankPred = NSPredicate(format:"SELF MATCHES %@", bankDetailsRegex)
        return bankPred.evaluate(with: bankInfo)
    }
    
    //Checks the length matches to the provided requirement
    static func checkLength(_ text: String, _ count: Int) -> Bool{
        return text.count >= count
    }
    
    //Check if the provided data is EMPTY or NULL
    static func isEmptyOrNil(_ text: String?) -> Bool {
        if text == "" || text == nil{
            return true
        }else{
            return false
        }
    }
}
