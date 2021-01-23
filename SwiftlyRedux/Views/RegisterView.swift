//
//  RegisterView.swift
//  Homes
//
//  Created by William Vabrinskas on 8/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import SwiftUI

struct RegisterView: View, LoginValidator {
  @Environment(\.theme) var theme
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.state) var state
  
  @State var email: String = ""
  @State var password: String = ""
  @State var errorText: String?
  @State var firstname: String = ""
  @State var lastname: String = ""
  
  public var onComplete: (() -> ())?
  
  var body: some View {
    ScrollView {
        HeaderView(viewModel: HeaderViewModel(title: "Register"))
          .padding(.top, 40)
        
        ClosableTextField(viewModel: CloseableTextFieldViewModel(buttonTitle: "close",
                                                                 placeholder: "first name",
                                                                 placeholderColor: .systemGray,
                                                                 textSize: 25,
                                                                 textAlignment: .left,
                                                                 textColor: theme.lightTextColor.uiColor()),
                          text: self.$firstname,
                          keyType: .default)
          .frame(width: 400, height: 30)
          .padding([.leading], 20)
          .padding(.top, 30)
        
        ClosableTextField(viewModel: CloseableTextFieldViewModel(buttonTitle: "close",
                                                                 placeholder: "last name",
                                                                 placeholderColor: .systemGray,
                                                                 textSize: 25,
                                                                 textAlignment: .left,
                                                                 textColor: theme.lightTextColor.uiColor()),
                          text: self.$lastname,
                          keyType: .default)
          .frame(width: 400, height: 30)
          .padding([.leading], 20)
          .padding(.top, 30)

        ClosableTextField(viewModel: CloseableTextFieldViewModel(buttonTitle: "close",
                                                                 placeholder: "email",
                                                                 placeholderColor: .systemGray,
                                                                 textSize: 25,
                                                                 textAlignment: .left,
                                                                 textColor: theme.lightButtonColor.uiColor()),
                          text: self.$email,
                          keyType: .default)
          .frame(width: 400, height: 30)
          .padding([.leading], 20)
          .padding(.top, 60)
        
        ClosableTextField(viewModel: CloseableTextFieldViewModel(buttonTitle: "close",
                                                                 placeholder: "password",
                                                                 placeholderColor: .systemGray,
                                                                 textSize: 25,
                                                                 textAlignment: .left,
                                                                 textColor: theme.lightButtonColor.uiColor(),
                                                                 isPassword: true),
                          text: self.$password,
                          keyType: .default)
          .frame(width: 400, height: 30)
          .padding([.leading], 20)
          .padding(.top, 30)
        
        Text(errorText ?? "")
          .font(Font.system(size: 12))
          .foregroundColor(theme.lightTextColor)
          .fontWeight(.bold)
          .padding([.top], 20)
          .padding([.leading], 20)
        
        loginButton()
        .padding([.top], 30)

        Spacer()
    }
    .background(theme.background).edgesIgnoringSafeArea(.all)

  }
  
  
  private func loginButton() -> AnyView {
    AnyView(Button(action: { self.done() } ) {
      Text("register")
        .font(Font.system(size: 20))
        .foregroundColor(.white)
        .fontWeight(.bold)
    }
    .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
    .background(theme.lightButtonColor)
    .cornerRadius(150)
    .shadow(radius: 5))
  }
  
  private func done() {
    let creds = Credentials(email: email, password: password)
    self.validate(credentials: creds) { (success, failedReasons) in
      guard success == true else {
        self.errorText = failedReasons
        return
      }
      
      let preprofile = PreProfile(firstName: self.firstname, lastName: self.lastname)
      
      self.state.register(credentials: creds, preProfile: preprofile) { (result) in
        switch result {
        case .success(_):
          self.errorText = "success!"
          DispatchQueue.main.async {
            self.presentationMode.wrappedValue.dismiss()
            self.onComplete?()
          }
          
        case  let .failure(err):
          self.errorText = err.localizedDescription
          
        }
      }
      
    }
  }
}


