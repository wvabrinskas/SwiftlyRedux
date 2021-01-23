//
//  FireStorageManager.swift
//  Homes
//
//  Created by William Vabrinskas on 1/22/21.
//  Copyright © 2021 William Vabrinskas. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

enum PhotoLocation {
  case profile(id: String)
  case feed(id: String)
  
  var name: String {
    switch self {
    case .feed:
      return "\(UUID().uuidString)"
    case .profile:
      return "profile-photo"
    }
  }
  
  var location: String {
    switch self {
    case let .feed(id):
      return "images/feed/\(id)/\(self.name).jpg"
    case let .profile(id):
      return "images/profile/\(id)/\(self.name).jpg"
    }
  }
}

enum UploadError: Error {
  case uploadEmpty
  case uploadErrorGeneric
  case downloadErrorGeneric
  case imageTooLarge
  
  var maxSize: String {
    return "1GB"
  }

  var localizedDescription: String {
    switch self {
    case .uploadEmpty:
      return "Image data is empty"
    case .uploadErrorGeneric:
      return "Could not upload image"
    case .downloadErrorGeneric:
      return "Could not download image url"
    case .imageTooLarge:
      return "Image is too large. Max size is: \(maxSize)"
    }
  }
  
}

protocol FireStorageManager {
  typealias FirebaseImageBlock = (Result<URL, Error>) -> ()

  var storage: StorageReference { get }
  var imageUploadSize: CGSize { get }
  
  func upload(_ location: PhotoLocation, image: UIImage?, complete: @escaping FirebaseImageBlock)
}

extension FireStorageManager {
  
  var storage: StorageReference {
    return Storage.storage().reference()
  }
  
  var imageUploadSize: CGSize {
    return CGSize(width: 400, height: 300)
  }
  
  func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
      newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
      newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func convert(_ image: UIImage) -> Data? {
    return image.jpegData(compressionQuality: 0.8)
  }
  
  func upload(_ location: PhotoLocation, image: UIImage?, complete: @escaping FirebaseImageBlock) {
    guard let image = image, let data = self.convert(image) else {
      complete(.failure(UploadError.uploadEmpty))
      return
    }
    
    //image larger than 1GB
    guard data.count < Int(1e+9) else {
      complete(.failure(UploadError.imageTooLarge))
      return
    }
    
    let imageRef = storage.child(location.location)
    
    let uploadTask = imageRef.putData(data, metadata: nil) { (metaData, error) in
      guard error == nil, let _ = metaData else {
        complete(.failure(error ?? UploadError.uploadErrorGeneric))
        return
      }
      
      imageRef.downloadURL { (url, error) in
        guard error == nil, let dUrl = url else {
          complete(.failure(error ?? UploadError.downloadErrorGeneric))
          return
        }
        
        complete(.success(dUrl))
      }
      
    }
    
    uploadTask.enqueue()
  }
  
}
