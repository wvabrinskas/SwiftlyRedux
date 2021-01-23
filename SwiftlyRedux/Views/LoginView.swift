//
//  LoginView.swift
//  Homes
//
//  Created by William Vabrinskas on 8/10/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import SwiftUI

struct LoginView: View, LoginValidator {
  @Environment(\.theme) var theme
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.state) var state
  
  @State var email: String = ""
  @State var password: String = ""
  @State var errorText: String?
  
  var body: some View {
    VStack(alignment: .center) {
      HeaderView(viewModel: HeaderViewModel(title: "Login"))
        .padding(.top, 40)
      
      ClosableTextField(viewModel: CloseableTextFieldViewModel(buttonTitle: "close",
                                                               placeholder: "email",
                                                               placeholderColor: .systemGray,
                                                               textSize: 20,
                                                               textAlignment: .left,
                                                               textColor: theme.lightTextColor.uiColor()),
                        text: self.$email,
                        keyType: .default)
        .frame(width: 300, height: 30)
        .padding([.leading], 20)
      ClosableTextField(viewModel: CloseableTextFieldViewModel(buttonTitle: "close",
                                                               placeholder: "password",
                                                               placeholderColor: .systemGray,
                                                               textSize: 20,
                                                               textAlignment: .left,
                                                               textColor: theme.lightTextColor.uiColor(),
                                                               isPassword: true),
                        text: self.$password,
                        keyType: .default)
        .frame(width: 300, height: 30)
        .padding([.leading], 20)
      
      loginButton()
        .padding([.top], 16)
      
      Text(errorText ?? "")
        .font(Font.system(size: 12))
        .foregroundColor(Color.indianRed)
        .fontWeight(.bold)
        .padding([.top], 20)
        .padding([.leading], 20)
      
      Spacer()
      
    }
    .background(theme.secondaryBackground).edgesIgnoringSafeArea(.all)
    
  }
  
  private func login() {
    self.errorText = nil
    
    let creds = Credentials(email: email, password: password)
    
    self.validate(credentials: creds) { (success, failedReasons) in
      guard success == true else {
        self.errorText = failedReasons
        return
      }
      
      self.state.login(credentials: creds) { (result) in
        switch result {
        case .success(_):
          self.presentationMode.wrappedValue.dismiss()
          
        case let .failure(error):
          self.errorText = error.localizedDescription
        }
      }
      
    }
  }
  
  private func loginButton() -> AnyView {
    AnyView(Button(action: { self.login() } ) {
      Text("login")
        .font(Font.system(size: 20))
        .foregroundColor(theme.lightTextColor)
        .fontWeight(.bold)
    }
    .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
    .background(theme.lightButtonColor)
    .cornerRadius(150)
    .shadow(radius: 5))
  }
  
}


