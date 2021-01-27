
//  Created by William Vabrinskas on 1/22/21.
//  Copyright © 2021 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import MobileCoreServices

struct ImagePicker: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode
  @Binding var image: UIImage?
  @Binding var url: URL?

  var pickerType: UIImagePickerController.SourceType
  var complete: ((_ image: UIImage?, _ url: URL?) -> ())?
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.allowsEditing = true
    picker.sourceType = pickerType
    picker.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)]
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

      if let mediaType = info[.mediaType] as? String {
        if mediaType == String(kUTTypeMovie) {
          if let mediaURL = info[.mediaURL] as? URL {
            parent.url = mediaURL
            parent.complete?(nil, mediaURL)
          }
        } else if mediaType == String(kUTTypeImage) {
          if let uiImage = info[.editedImage] as? UIImage {
            parent.image = uiImage
            parent.complete?(uiImage, nil)
          }
        }
      }
      
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
  
}

