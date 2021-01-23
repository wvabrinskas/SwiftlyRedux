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

class VideoModule: Module {
  typealias ObjectType = Bool
  @Published var object: ObjectType? = false
  var objectPublisher: Published<ObjectType?>.Publisher { $object }
  
  public var videoPlaying: Bool = false {
    didSet {
      self.object = videoPlaying
    }
  }
  
  public static func getId(from videoUrl: String, type: VideoType = .youtube) -> String? {
    switch type {
    case .youtube:
        //covers both types of URLs for YT videos
      if let query = URLComponents(string: videoUrl)?.queryItems?.first(where: { $0.name == "v" })?.value {
        return query
      }
      
      if let path = URLComponents(string: videoUrl)?.path.dropFirst() {
        return String(path)
      }
      
      return nil
    case .vimeo:
      return nil
    }
  }
}

extension VideoModule: YouTubePlayerDelegate {
  func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
    switch playerState {
    case .Playing:
      self.videoPlaying = true
    case .Paused, .Ended:
      self.videoPlaying = false
    default:
      break
    }
  }
  
  func playerReady(_ videoPlayer: YouTubePlayerView) {
    print("VIDEO READY")
  }
}
