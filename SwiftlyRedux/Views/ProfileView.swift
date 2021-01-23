//
//  ProfileView.swift
//  Homes
//
//  Created by William Vabrinskas on 8/29/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct ProfileView: View {
  let viewModel: ProfileViewModel
  
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  @Environment(\.presentationMode) var presentationMode
  
  @State var showLoading: Bool = false
  @State var showSheet: Bool = false
  @State var editing: Bool = false
  @State var profile: Profile?
  @State private var inputImage: UIImage?
  @State var activeSheet: ActiveSheet?
  @State var loadedImage: Bool = false

  enum ActiveSheet: Identifiable {
    case imagePicker
    
    var id: Int {
      hashValue
    }
  }
  
  var body: some View {
    VStack(alignment: .center, spacing: 10) {
      Button(action: {
        self.activeSheet = .imagePicker
      }, label: {
        profileImage()
          .clipShape(Circle())
      })
      .padding()
      
      Text("\(self.viewModel.firstname) \(self.viewModel.lastname)")
        .font(Font.system(size: 30))
        .foregroundColor(theme.lightTextColor)
        .fontWeight(.bold)
        .padding([.bottom, .top], 20)
        .frame(maxWidth: .infinity, alignment: .center)
      
      
      logoutButton()
      
      Spacer()
    }
    .onReceive(self.state.subscribe(type: .auth)) { (user: AuthModule.ObjectType?) in
      self.profile = user
    }
    .onAppear {
      guard let profile: Profile = self.state.object(type: .auth) else {
        return
      }
      self.profile = profile
    }
    .loadable(title: "Uploading photo", showing: self.$showLoading)
    .sheet(item: self.$activeSheet) { sheet in
      switch sheet {
      case .imagePicker:
        ImagePicker(image: self.$inputImage) { image in
          self.uploadPhoto(image)
        }
      }
    }
    .background(theme.background).edgesIgnoringSafeArea(.all)
  }
  
  private func uploadPhoto(_ image: UIImage?) {
    guard let image = image else {
      return
    }
    
    guard let profile = profile else {
      return
    }
    self.showLoading = true
    
    self.state.uploadImage(.profile(id: profile.userId), image: image) { (url) in
      DispatchQueue.main.async {
        self.showLoading = false
      }
    }
  }
  
  private func logout() {
    state.logout { (result) in
      switch result {
      case .success(_):
        self.presentationMode.wrappedValue.dismiss()
        
      case.failure(_) :
        return
      }
    }
  }
  
  
  private func logoutButton() -> AnyView {
    AnyView(Button(action: { self.logout() } ) {
      Text("sign out")
        .font(Font.system(size: 20))
        .foregroundColor(theme.lightTextColor)
        .fontWeight(.bold)
    }
    .frame(width: 100, height: 50)
    .background(Color.clear))
  }
  
  private func profileImage() -> AnyView {
    
    if let profile: Profile = self.state.object(type: .auth),
       let urlS = profile.profileImage,
       let url = URL(string: urlS) {
      
      let imageView =
        WebImage(url: url)
        .resizable()
        .placeholder {
          Color.lightSlateGray
        }
        .indicator(.activity)
        .transition(.fade(duration: 0.5))
      
      return AnyView(imageView
                      .frame(width: 200, height: 200, alignment: .center))
    }
    
    return
      AnyView(Image(systemName: "person.crop.circle.badge.plus")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(theme.lightTextColor)
              .frame(width: 200, height: 200, alignment: .center))
    
  }
  
}


