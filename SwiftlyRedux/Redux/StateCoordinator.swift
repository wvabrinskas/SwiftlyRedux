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

enum CoordinatorError: Error {
   case invalidType
   case empty
   
   var localizedDescription: String {
     switch self {
     case .invalidType:
       return "invalid type, cannot convert"
     case .empty:
       return "empty object error"
     }
   }
 }


//MARK: Base
class StateCoordinator {
  private let auth = AuthSubscription()
  private let media = MediaSubscription()
  private let session = SessionSubscription()
  private let feed = FeedSubscription()
  private let comment = CommentSubscription()
  
  enum SubscriptionType {
    case auth
    case media
    case session
    case feed
    case comment
  }

  public func object<TType>(type: SubscriptionType) -> TType? {
    switch type {
    case .auth:
      return self.auth.obj()
    case .session:
      return self.session.obj()
    case .media:
      return self.media.obj()
    case .feed:
      return self.feed.obj()
    case .comment:
      return self.comment.obj()
    }
  }
  
  public func subscribe<TType>(type: SubscriptionType) -> Published<TType?>.Publisher {
    switch type {
    case .auth:
      return self.auth.publisher()
    case .session:
      return self.session.publisher()
    case .media:
      return self.media.publisher()
    case .feed:
      return self.feed.publisher()
    case .comment:
      return self.comment.publisher()
    }
  }
}

//MARK: Comments
extension StateCoordinator {
  public func addComment(comment: String, to media: Media, complete: FirebaseReturnBlock?) {
    guard let user = self.auth.module.object else {
      complete?(.failure(AuthModule.AuthError.notLoggedIn))
      return
    }

    let comment = Comment(comment: comment,
                          poster: user.userId,
                          mediaRefId: media.id,
                          posterImage: user.profileImage,
                          posterUsername: user.username)
    
    self.comment.module.addComment(comment: comment, to: media) { [weak self] (result) in
      complete?(result)
      self?.getFeed(id: media.feedRefId)
    }
  }
  
  public func removeComment(comment: Comment, from media: Media, complete: FirebaseReturnBlock?) {
    self.comment.module.removeComment(comment: comment, from: media) { [weak self] (result) in
      complete?(result)
      self?.getFeed(id: media.feedRefId)
    }
  }
  
  public func getComments(media: Media) {
    self.comment.module.getComments(media: media)
  }
}

//MARK: Feed
extension StateCoordinator {
  public func getFeed(id: String) {
    self.feed.module.getFeed(id: id) { [weak self] (feed) in
      if let feed = feed {
        self?.media.module.get(feed: feed)
      }
    }
  }
}

//MARK: Firebase
extension StateCoordinator: FirestoreManager, FirebaseRealtimeManager {

}

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
  
  public func uploadProfileImage(image: UIImage?, complete: @escaping (_ url: URL?) -> ()) {
    self.auth.module.uploadImage(image: image, complete: complete)
  }
  
  public func getUserProfile(id: String, complete: @escaping (_ result: Result<Profile, Error>) -> ()) {
    self.auth.module.getUserProfile(id: id, complete: complete)
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

//MARK: Media
extension StateCoordinator {
  func setVideoDelegate(_ view: inout YouTubePlayerView) {
    view.delegate = self.media.module
  }
  
  public func getFeedMedia(feed: Feed) {
    self.media.module.get(feed: feed)
  }
  
  public func uploadMedia(media: Media, to feed: Feed, complete: FirestoreManager.FirebaseReturnBlock?) {
    self.media.module.addMedia(media: media, to: feed) { [weak self] (result) in
      //update user profile
      //should be done automatically using the the auth state
      complete?(result)
      self?.auth.module.refreshUser()
    }
  }
  
  public func getVideoId(for url: String) -> String? {
    return self.media.module.getVideoId(from: url)
  }
  
  public func uploadMediaImage(feedId: String, image: UIImage?, complete: @escaping (_ url: URL?) -> ()) {
    self.media.module.upload(.feed(id: feedId), image: image) { (result) in
      switch result {
      case let .success(url):
      complete(url)
      case let .failure(error):
        complete(nil)
        print(error)
      }
    }
  }
  
  public func uploadMediaVideo(feedId: String, url: URL?, complete: @escaping (_ url: URL?) -> ()) {
    self.media.module.uploadVideo(.feed(id: feedId), url: url) { (result) in
      switch result {
      case let .success(url):
      complete(url)
      case let .failure(error):
        complete(nil)
        print(error)
      }
    }
  }
  
  public func deleteMedia(media: Media, complete: MediaModule.FirebaseReturnBlock?) {
    self.media.module.deleteMedia(media: media) { (result) in
      switch result {
      case .success:
        self.feed.module.removeMedia(media: media, complete: complete)
      case let .failure(error):
        complete?(.failure(error))
      }
    }
  }
}
