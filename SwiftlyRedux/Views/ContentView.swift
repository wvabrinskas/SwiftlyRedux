//
//  ContentView.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/22/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  
  enum ActionSheet: Identifiable {
    case login, register, profile
    
    var id: Int { hashValue }
  }
  
  @State private var activeSheet: ActionSheet?
  @State private var showLogin: Bool = false
  @State private var profile: Profile?
  @State private var loading: Bool = true
  
  private var bodyAnimation: Animation {
    Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)
  }
  
  var body: some View {

    VStack(spacing: 20) {
      HStack {
        self.profileButton()
          .animation(self.bodyAnimation)
      }
      .frame(maxWidth: .infinity, maxHeight: 40, alignment: .trailing)
      .padding(.trailing, 20)
      
      HeaderView(viewModel: HeaderViewModel(title: "Swiftly Redux",
                                            subtitle: "an example of modular redux in swift"))
        .padding([.leading, .trailing], 20)
    
      Spacer()
      Image("swift")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 300)
      
      Spacer()
      
      if self.profile == nil {
        self.buttonStack()
          .transition(.scale)
      }

    }
    .padding(.top, 100)
    .onReceive(state.subscribe(type: .auth), perform: { (user: AuthModule.ObjectType?) in
      self.profile = user
      self.loading = false
    })
    .sheet(item: self.$activeSheet) { sheet in
      switch sheet {
      case .login:
        LoginView()
      case .register:
        RegisterView()
      case .profile:
        profileView()
      }
    }
    .animation(self.bodyAnimation)
    .background(theme.secondaryBackground).edgesIgnoringSafeArea(.all)

  }
  
  private func buttonStack() -> some View {
    VStack(spacing: 10) {
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
  }
  
  private func profileView() -> AnyView {
    guard let profile = profile else {
      return AnyView(EmptyView())
    }
    return AnyView(ProfileView(viewModel: ProfileViewModel(profile: profile)))
  }
  
  private func login() {
    self.activeSheet = .login
  }
  
  private func register() {
    self.activeSheet = .register
  }
  
  private func profilePressed() {
    self.activeSheet = .profile
  }
  
  private func profileButton() -> AnyView {
    guard let profile = self.profile else {
      return AnyView(EmptyView())
    }
    
    if let profileUrl = profile.profileImage {
      
      return AnyView(Button(action: {
        self.profilePressed()
      }, label: {
        WebImage(url: URL(string: profileUrl))
          .resizable()
          .placeholder {
            Color.lightSlateGray
          }
          .indicator(.activity)
          .transition(.fade(duration: 0.5))
      })
      .frame(width: 40, height: 40)
      .clipShape(Circle())
      )
      
    } else {
      let viewModel = ButtonViewModel(buttonImage: "person",
                                      size: CGSize(width: 40, height: 40),
                                      backgroundColor: Color.ghostWhite,
                                      imageSize: 20)
      return AnyView(ButtonView(viewModel: viewModel) {
        self.profilePressed()
      })
    }
 
  }
  
}
