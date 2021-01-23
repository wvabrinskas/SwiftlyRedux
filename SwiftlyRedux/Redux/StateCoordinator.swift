//
//  StateCoordinator.swift
//  Homes
//
//  Created by William Vabrinskas on 9/20/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
//figure out how to remove this from here
import YouTubePlayer

//MARK: Base
class StateCoordinator {
  private let auth = AuthSubscription()
  private let video = VideoSubscription()
  private let session = SessionSubscription()
  
  //public states
  public var homeTapped: Int?

  enum SubscriptionType {
    case auth
    case video
    case session
  }
  
  public func object<TType>(type: SubscriptionType) -> TType? {
    switch type {
    case .auth:
      return self.auth.obj()
    case .session:
      return self.session.obj()
    case .video:
      return self.video.obj()
    }
  }
  
  public func subscribe<TType>(type: SubscriptionType) -> Published<TType?>.Publisher {
    switch type {
    case .auth:
      return self.auth.publisher()
    case .session:
      return self.session.publisher()
    case .video:
      return self.video.publisher()
    }
  }
}

//MARK: Firebase
extension StateCoordinator: FirestoreManager, FirebaseRealtimeManager {}

//MARK: Auth
extension StateCoordinator {
  public func hasCachedValidUser() -> Bool {
    return self.auth.module.hasCachedValidUser()
  }
  
  public func signInToAccessData(complete: @escaping AuthModule.FirebaseReturnBlock) {
    self.auth.module.signInToAccessData(complete: complete)
  }
  
  public func logout(complete: AuthModule.FirebaseReturnBlock?) {
    self.auth.module.logout(complete: complete)
  }
  
  public func refreshUser() {
    self.auth.module.refreshUser()
  }
  
  public func login(credentials: Credentials, complete: @escaping AuthModule.FirebaseReturnBlock) {
    self.auth.module.login(credentials: credentials, complete: complete)
  }
  
  public func register(credentials: Credentials, preProfile: PreProfile, complete: @escaping FirebaseReturnBlock) {
    self.auth.module.register(credentials: credentials, preProfile: preProfile, complete: complete)
  }
  
  public func uploadImage(_ location: PhotoLocation, image: UIImage?, complete: @escaping (_ url: URL?) -> ()) {
    switch location {
    case .profile:
      self.auth.module.uploadImage(image: image, complete: complete)
    case .story:
      print("upload to story")
    }
  }
}

//MARK: Session
extension StateCoordinator {
  func setRealtimeSession(sessionKey: String) {
    let user: Profile? = self.object(type: .auth)
    self.session.module.setRealtimeSession(sessionKey: sessionKey, user: user)
  }
  
  func joinRealtimeSession(sessionKey: String,
                           complete: ((_ result: Result<RealtimeSession?, Error>) -> ())? = nil) {
    let user: Profile? = self.object(type: .auth)
    self.session.module.joinRealtimeSession(sessionKey: sessionKey, user: user, complete: complete)
  }
  
  func keepSync(_ sessionKey: String) {
    self.session.module.keepSync(sessionKey)
  }
  
  func changeVideoPlayState(sessonKey: String, play: Bool, complete: ((_ result: Result<Bool, Error>) -> ())? = nil) {
    self.session.module.changeVideoPlayState(sessonKey: sessonKey, play: play, complete: complete)
  }
}

//MARK: Video
extension StateCoordinator {
  func setVideoDelegate(_ view: inout YouTubePlayerView) {
    view.delegate = self.video.module
  }
}
