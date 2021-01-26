//
//  MediaUploadView.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/25/21.
//

import SwiftUI

struct MediaUploadView: View {
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  @Environment(\.presentationMode) var mode

  var viewModel: MediaUploadViewModel
  
  @State var showImagePicker: Bool = false
  @State var image: UIImage?
  @State var imageTypeToShow: ImageType?
  @State var description: String = ""
  @State var uploading: Bool = false

  enum ImageType: Identifiable {
    case camera, library
    
    var id: Int { hashValue }
  }

  var body: some View {
    VStack {
      HeaderView(viewModel: HeaderViewModel(title: "Upload media"))
        .padding(.top, 50)
      if let image = self.image {
        
        Image(uiImage: image)
          .resizable()
          .aspectRatio(16/9, contentMode: .fit)
          .cornerRadius(25)
          .padding()
        
      } else {
        RoundedRectangle(cornerRadius: 25)
          .foregroundColor(theme.secondaryBackground)
          .aspectRatio(16/9, contentMode: .fit)
          .padding()
      }
      uploadButtonStack()
        .padding(.top, 10)
      
      Text("description")
        .fontWeight(.light)
        .font(Font.system(size: 12))
        .foregroundColor(theme.lightTextColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)

      TextView(viewModel: TextViewModel(textSize: 20,
                                        textColor: theme.lightTextColor.uiColor()),
               text: self.$description) { (value) in
        
      }
      .frame(height: 120)
      .padding([.leading, .trailing], 26)
      .padding(.top, 5)
      .overlay(RoundedRectangle(cornerRadius: 25)
                .stroke(Color(.sRGB, white: 1.0, opacity: 0.3), lineWidth: 2)
                .padding([.leading, .trailing], 26)
                .padding(.top, 5))
          
      Button(action: { self.upload() } ) {
        Text("upload")
          .fontWeight(.bold)
          .font(Font.system(size: 20))
          .foregroundColor(theme.lightTextColor)
          .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
      }
      .frame(width: theme.buttonSize.width, height: theme.buttonSize.height)
      .background(theme.lightButtonColor)
      .cornerRadius(150)
      .shadow(radius: 5)
      .padding(.top, 50)
      
      Spacer()

    }
    .sheet(item: self.$imageTypeToShow) { (type) in
      switch type {
      case .camera:
        uploadPicView(source: .camera)
      case .library:
        uploadPicView(source: .photoLibrary)
      }
    }
    .loadable(title: "uploading..",
              showing: self.$uploading,
              background: theme.secondaryBackground,
              textColor: theme.lightTextColor)
    .background(theme.background).edgesIgnoringSafeArea(.all)
  }
  
  private func upload() {
    guard let image = image else {
      return
    }
    
    self.uploading = true
    
    self.state.uploadMediaImage(feedId: self.viewModel.feed.id, image: image) { (url) in
      guard let url = url else {
        return
      }
      
      let media = Media(url: url.absoluteString, type: .photo, description: self.description)
      self.state.uploadMedia(media: media, to: self.viewModel.feed) { (result) in
        self.uploading = false

        switch result {
        case .success:
          self.mode.wrappedValue.dismiss()
        case let .failure(error):
          print(error)
        }
      }
    }
  }
  
  private func uploadButtonStack() -> AnyView {
    AnyView(HStack(spacing: 100) {
      Button(action: {
        self.imageTypeToShow = .camera
      } ) {
        Image(systemName: "camera")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(theme.lightTextColor)
          .frame(width: 30, height: 30)
      }
      .background(Color.clear)
      
      Button(action: {
        self.imageTypeToShow = .library
      } ) {
        Image(systemName: "photo")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(theme.lightTextColor)
          .frame(width: 30, height: 30)
      }
      .background(Color.clear)
    })
  }
  
  private func uploadPicView(source: UIImagePickerController.SourceType) -> ImagePicker {
    ImagePicker(image: self.$image, pickerType: source)
  }
}
