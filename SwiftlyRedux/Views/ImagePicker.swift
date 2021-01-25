
//  Created by William Vabrinskas on 1/22/21.
//  Copyright © 2021 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode
  @Binding var image: UIImage?
  var pickerType: UIImagePickerController.SourceType
  var complete: ((_ image: UIImage?) -> ())?
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.allowsEditing = true
    picker.sourceType = pickerType
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
      if let uiImage = info[.editedImage] as? UIImage {
        parent.image = uiImage
        parent.complete?(uiImage)
      }
      
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
  
}

