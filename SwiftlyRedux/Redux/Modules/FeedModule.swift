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
  
  
  func getFeed(id: String) {
    self.getDoc(ref: .feed(id: id)) { (result: Result<Feed, Error>) in
      switch result {
      case let .success(feed):
        self.object = feed
      case let .failure(error):
        print(error)
        self.object = Feed(id: id, media: [])
      }
    }
  }
  
}
