//
//  InputValidation.swift
//  Ordernise
//
//  Created by Aaron on 26/07/2021.
//
import Foundation

class InputValidation{
    
    static let OTPLength = 6
    static let PasswordLength = 6
    
    public static func validateEmailAddress(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
  
    
    public static func validatePassword(password: String) -> Bool{
        return password.count >= self.PasswordLength
    }


}

