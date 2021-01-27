//
//  FeedModule.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/25/21.
//

import Foundation


class FeedModule: Module, FirestoreManager, FireStorageManager {

  typealias ObjectType = Feed
  @Published var object: Feed?
  var objectPublisher: Published<Feed?>.Publisher { $object }
  
  
  func getFeed(id: String, complete: ((_ feed: Feed?) -> ())? = nil) {
    self.getDoc(ref: .feed(id: id)) { (result: Result<Feed, Error>) in
      switch result {
      case let .success(feed):
        self.object = feed
        complete?(feed)
      case let .failure(error):
        print(error)
        complete?(nil)
        self.object = Feed(id: id, media: [])
      }
    }
  }
  
  func removeMedia(media: Media, complete: FirebaseReturnBlock?) {
    guard let feed = self.object else {
      return
    }
    let mediaStrings = feed.media.filter({ $0 != media.id })
    
    self.updateDoc(ref: .feed(id: feed.id), value: ["media" : mediaStrings]) { (result) in
      switch result {
      case .success:
        complete?(.success(true))
        self.object = Feed(id: feed.id, media: mediaStrings)
      case let .failure(error):
        complete?(.failure(error))
      }
    }
  }
  
}
