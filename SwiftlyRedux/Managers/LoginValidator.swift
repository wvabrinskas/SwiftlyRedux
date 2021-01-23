//
//  LoginValidator.swift
//  Homes
//
//  Created by William Vabrinskas on 8/10/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import Navajo_Swift

public struct Credentials {
  var email: String
  var password: String
  
  static func `default`() -> Credentials {
    let email = "test@roof.com"
    let password = "yGXrkitMEPiNY9FLhT"
    return Credentials(email: email, password: password)
  }
}

protocol LoginValidator {
  func validate(credentials: Credentials, complete: (_ success: Bool, _ failedRules: String?) -> ())
  func validator() -> PasswordValidator
}

extension LoginValidator {
  
  func validator() -> PasswordValidator {
    let lengthRule = LengthRule(min: 6, max: 24)
    let lowercaseRule = RequiredCharacterRule(preset: .lowercaseCharacter)
    let uppercaseRule = RequiredCharacterRule(preset: .uppercaseCharacter)
    let numberRule = RequiredCharacterRule(preset: .decimalDigitCharacter)

    let validator = PasswordValidator(rules: [lengthRule, lowercaseRule, uppercaseRule, numberRule])
    
    return validator
  }
  
  func validate(credentials: Credentials, complete: (_ success: Bool, _ failedRules: String?) -> ()) {
    guard credentials.email.isEmpty == false else {
      complete(false, "emtpy email")
      return
    }
    
    let validator = self.validator()

    let password = credentials.password
      
    if let failing = validator.validate(password) {
      complete(false, failing.map({ return $0.localizedErrorDescription }).joined(separator: "\n"))
    } else {
      complete(true, nil)
    }
  }
}
