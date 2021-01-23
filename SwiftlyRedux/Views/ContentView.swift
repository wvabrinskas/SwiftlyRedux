//
//  ContentView.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/22/21.
//

import SwiftUI

struct ContentView: View {
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  
  enum ActionSheet: Identifiable {
    case login, register
    
    var id: Int { hashValue }
  }
  
  @State private var activeSheet: ActionSheet?
  @State private var showLogin: Bool = false
  
  var body: some View {

    VStack(spacing: 20) {
      HeaderView(viewModel: HeaderViewModel(title: "Swiftly Redux",
                                            subtitle: "an example of modular redux in swift"))
        .padding([.top], 100)
        .padding([.leading, .trailing], 20)

      Spacer()
      Image("swift")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 300)
      
      Spacer()

      Button(action: { self.login() } ) {
        Text("login")
          .fontWeight(.bold)
          .font(Font.system(size: 20))
          .foregroundColor(theme.lightTextColor)
          .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
      }
      .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
      .background(theme.lightButtonColor)
      .cornerRadius(150)
      .shadow(radius: 5)
      .padding(.top, 30)
      
      Button(action: { self.register() } ) {
        Text("register")
          .font(Font.system(size: 20))
          .foregroundColor(theme.darkTextColor)
          .fontWeight(.bold)
          .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
      }
      .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
      .background(theme.darkButtonColor)
      .cornerRadius(150)
      .shadow(radius: 5)
      .padding(.bottom, 50)

    }
    .sheet(item: self.$activeSheet) { sheet in
      switch sheet {
      case .login:
        LoginView()
      case .register:
        EmptyView()
      }
    }
    .background(theme.secondaryBackground).edgesIgnoringSafeArea(.all)

  }
  
  private func login() {
    
  }
  
  private func register() {
    
  }
}
