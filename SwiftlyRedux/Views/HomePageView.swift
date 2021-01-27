//
//  ContentView.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/22/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomePageView: View {
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  
  enum ActionSheet: Identifiable {
    case login, register, profile, upload
    
    var id: Int { hashValue }
  }
  
  @State private var activeSheet: ActionSheet?
  @State private var showLogin: Bool = false
  @State private var profile:  AuthModule.ObjectType?
  @State private var loading: Bool = true
  @State private var feed: Feed?
  @State private var showUploadSheet: Bool = false
  
  private var bodyAnimation: Animation {
    Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)
  }
  
  var body: some View {

    VStack(spacing: 20) {
      HStack {
        let username = (self.profile?.username ?? "").lowercased()
        HeaderView(viewModel: HeaderViewModel(title: self.profile == nil ? "Swiftly Redux" : "Media feed",
                                              subtitle: self.profile == nil ? "an example of modular redux in swift" : username))
          .padding([.leading, .trailing], 20)
          .padding(.top, 10)

        self.profileButton()
          .animation(self.bodyAnimation)
      }
      .frame(maxWidth: .infinity, maxHeight: 40, alignment: .trailing)
      .padding(.trailing, 20)
      
      ZStack {
        if let feed = self.feed, let _ = self.profile {
          FeedView(viewModel: FeedViewModel(feed: feed))
            .background(theme.secondaryBackground)
        }
        VStack {
          Spacer()
          if self.profile != nil {
            uploadButtonStack()
              .padding(.bottom, 50)
              .padding(.top, 30)
              .frame(maxWidth: .infinity, alignment: .center)
              .background(LinearGradient(gradient: Gradient(colors: [Color(.sRGB, white: 0.0, opacity: 0.7), .clear]),
                                         startPoint: .bottom,
                                         endPoint: .top))
          }
        }

        .edgesIgnoringSafeArea(.all)
      }
    
      if self.profile == nil {
        Spacer()
        Image("swift")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 300, height: 300)
        
        Spacer()
        self.buttonStack()
          .transition(.scale)
      }
      
      Spacer()

    }
    .onAppear {
      if let user = profile {
        self.state.getFeed(id: user.feed)
      }
    }
    .padding(.top, 100)
    .onReceive(state.subscribe(type: .auth), perform: { (user: AuthModule.ObjectType?) in
      self.profile = user
      if let user = user {
        self.state.getFeed(id: user.feed)
      }
      self.loading = false
    })
    .onReceive(state.subscribe(type: .feed), perform: { (feed: FeedModule.ObjectType?) in
      self.feed = feed
    })
    .sheet(item: self.$activeSheet) { sheet in
      switch sheet {
      case .login:
        LoginView()
      case .register:
        RegisterView()
      case .profile:
        profileView()
      case .upload:
        
        if let feed = self.feed {
          MediaUploadView(viewModel: MediaUploadViewModel(feed: feed))
        } else {
          EmptyView()
        }
      }
    }
    .actionSheet(isPresented: self.$showUploadSheet) {
      SwiftUI.ActionSheet(title: Text("Upload"), message: Text(""),
                  buttons: [
                    .default(Text("Photo"), action: {  }),
                    .default(Text("Video"), action: {  }),
                    .destructive(Text("Close"))])
    }
    .animation(self.bodyAnimation)
    .background(theme.secondaryBackground).edgesIgnoringSafeArea(.all)

  }
  
  private func uploadButtonStack() -> AnyView {
    AnyView(
      HStack {
        Button(action: { self.activeSheet = .upload } ) {
        Image(systemName: "plus.circle")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(theme.lightTextColor)
          .frame(width: 30, height: 30)
      }
      .background(Color.clear)

    })
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
    guard let profile = profile, let feed = feed else {
      return AnyView(EmptyView())
    }
    return AnyView(ProfileView(viewModel: ProfileViewModel(profile: profile, feed: feed)))
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
