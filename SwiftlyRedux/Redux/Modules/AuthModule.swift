
//  Created by William Vabrinskas on 8/23/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase
import Combine
import SimpleApiClient
import FirebaseFirestore

class AuthModule: Module, FirestoreManager {
  typealias ObjectType = Profile
  @Published var object: ObjectType?
  var objectPublisher: Published<ObjectType?>.Publisher { $object }

  private var authHandle: AuthStateDidChangeListenerHandle?
  public var user: Profile? {
    didSet {
      self.object = user
    }
  }
  
  public enum AuthError: Error {
    case notLoggedIn
    
    var localizedDescription: String {
      switch self {
      case .notLoggedIn:
        return "Please log in to post comments"
      }
    }
  }
    
  deinit {
    if let handle = authHandle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }
  
  public func hasCachedValidUser() -> Bool {
    return Auth.auth().currentUser != nil && !self.signedInUserIsDefault(Auth.auth().currentUser)
  }
  
  public func signInToAccessData(complete: @escaping FirebaseReturnBlock) {
    let credentials = Credentials.default()
    self.login(credentials: credentials, complete: complete)
  }
  
  public init() {
    self.setProfile(Auth.auth().currentUser)

    let authHandle = Auth.auth().addStateDidChangeListener({ [weak self] (auth, user) in
      guard self?.signedInUserIsDefault() == false else {
        return
      }
      self?.setProfile(user)
    })
    self.authHandle = authHandle
  }
  
  //grabs a user profile. If we were to scale this we would need to move this to a lamba on Firebase
  //that returns the neccessary data we want, since we don't want the application to pull the entire user profile
  //Security risk!
  public func getUserProfile(id: String, complete: @escaping (_ result: Result<Profile, Error>) -> ()) {
    self.getDoc(ref: .users(id: id), complete: complete)
  }
  
  public func login(credentials: Credentials, complete: @escaping FirebaseReturnBlock) {
    Auth.auth().signIn(withEmail: credentials.email, password: credentials.password) { (result, error) in
      guard let user = result?.user, error == nil else {
        complete(.failure(error ?? CoordinatorError.invalidType))
        return
      }
      
      if self.signedInUserIsDefault(user) == false {
        self.setProfile(user, complete: complete)
      } else {
        complete(.success(true))
      }
    }
  }
  
  public func register(credentials: Credentials, preProfile: PreProfile, complete: @escaping FirebaseReturnBlock) {
    Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
      guard let user = result?.user, error == nil else {
        complete(.failure(error ?? CoordinatorError.invalidType))
        return
      }
      let profile = Profile(id: user.uid, preProfile: preProfile)
      self.addProfile(profile, complete: complete)
    }
  }
  
  public func logout(complete: FirebaseReturnBlock?) {
    do {
      try Auth.auth().signOut()
      self.user = nil
      complete?(.success(true))
    } catch {
      complete?(.failure(error))
    }
  }
  
  public func refreshUser() {
    guard let user = user else {
      return
    }
    
    self.getDoc(ref: .users(id: user.userId)) { [weak self] (result: Result<Profile?, Error>) in
      switch result {
      case let .success(profile):
        self?.user = profile
      case .failure(_):
        return
        
      }
    }
  }
  
  public func signedInUserIsDefault(_ user: User? = nil) -> Bool  {
    return self.user?.userId == "zQa6VRBcdMaCeNouXyWnFrnXlWy2" || user?.uid == "zQa6VRBcdMaCeNouXyWnFrnXlWy2"
  }
  
  private func setProfile(_ user: User?, complete: FirebaseReturnBlock? = nil) {
    
    guard let user = user else {
      return
    }
    
    self.getDoc(ref: .users(id: user.uid)) { [weak self] (value: Result<Profile?, Error>) in
      
      switch value {
      case let .success(profile):
        self?.user = profile
        complete?(.success(true))
        
      case let .failure(error):
        complete?(.failure(error))
      }
    }
  }
  
  private func addProfile(_ profile: Profile, complete: FirebaseReturnBlock? = nil) {
    
    self.setDoc(ref: .users(id: profile.userId), value: profile) { [weak self] (result) in
      
      switch result {
        
      case .success(_):
        self?.user = profile
        complete?(.success(true))
      
      case let .failure(error):
        complete?(.failure(error))
      }
      
    }
  
  }
}

extension AuthModule: FireStorageManager {
  
  func uploadImage(image: UIImage?, complete: @escaping (_ url: URL?) -> ()) {
    
    guard let user = self.user else {
      complete(nil)
      return
    }
    
    self.upload(PhotoLocation.profile(id: user.userId), image: image) { (result) in
      switch result {
      case let .success(url):

        let updates = ["profileImage" : url.absoluteURL]
        
        self.updateDoc(ref: .users(id: user.userId), value: updates) { (result) in
          switch result {
            
          case .success(_):
            self.refreshUser()
            complete(url)
          case let .failure(error):
            print(error.localizedDescription)
            complete(nil)
            return
          }
        }
        
      case let .failure(err):
        print(err.localizedDescription)
        complete(nil)
      }
    }
  }
}
