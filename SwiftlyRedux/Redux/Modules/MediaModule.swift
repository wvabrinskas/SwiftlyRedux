//
//  DataCoordinator.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import SimpleApiClient
import YouTubePlayer

class MediaModule: Module, FirestoreManager, FireStorageManager {
  typealias ObjectType = [Media]
  
  @Published var object: ObjectType? = []
  
  var objectPublisher: Published<ObjectType?>.Publisher { $object }

  //no need to bubble up result since this is managed by the publisher
  //alternatively we COULD make an optional return block
  public func get(feed: Feed) {
    
    DispatchQueue.global(qos: .userInitiated).async {
      let group = DispatchGroup()
      
      var intermediateMedia: [Media] = []
      
      feed.media.forEach { [weak self] (id) in
        group.enter()
        
        self?.get(media: id, complete: { (result) in
          switch result {
          case let .success(home):
            intermediateMedia.append(home)
            group.leave()
          case .failure(_):
            group.leave()
          }
        })
      }
    
      //sort by date
      group.notify(queue: .main) { [weak self] in
        self?.object = intermediateMedia.compactMap({ $0 }).sorted(by: { $0.uploadDate > $1.uploadDate })
      }
    }

  }
  
  public func get(media id: String,
                  complete: @escaping (_ result: Result<Media, Error>) -> ()) {
    
    self.getDoc(ref: .media(id: id), complete: complete)
  }
  
  //we want to bubble up this result block for user interaction
  public func addMedia(media: Media, to feed: Feed, complete: FirebaseReturnBlock?) {
    //upload media to media document
    self.setDoc(ref: .media(id: media.id), value: media) { [weak self] (result) in
      switch result {
      case .success:
        var oldMedia = feed.media
        oldMedia.append(media.id)
        
        let updates = ["media" : oldMedia]
        
        //if media upload successful, update the feed document
        self?.updateDoc(ref: .feed(id: feed.id), value: updates) { [weak self] (updateResult) in
          switch result {
          case .success:
            var oldMediaObjects = self?.object
            oldMediaObjects?.append(media)
            self?.object = oldMediaObjects
            
          case let .failure(error):
            complete?(.failure(error))
          }
        }
        
      case let .failure(error):
        complete?(.failure(error))
      }
    }
  }
}

//MARK: Video playback state
extension MediaModule: YouTubePlayerDelegate {
  
  public static func getVideoId(from videoUrl: String) -> String? {
    //covers both types of URLs for YT videos
    if let query = URLComponents(string: videoUrl)?.queryItems?.first(where: { $0.name == "v" })?.value {
      return query
    }
    
    if let path = URLComponents(string: videoUrl)?.path.dropFirst() {
      return String(path)
    }
    
    return nil
  }
  
  func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
//    switch playerState {
//    case .Playing:
//      self.videoPlaying = true
//    case .Paused, .Ended:
//      self.videoPlaying = false
//    default:
//      break
//    }
  }
  
  func playerReady(_ videoPlayer: YouTubePlayerView) {
    print("VIDEO READY")
  }
}
