//
//  Video.swift
//  Homes
//
//  Created by William Vabrinskas on 8/26/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

public enum VideoType: String, Codable {
  case youtube
  case vimeo
}

public struct Video: Codable {
  var id: String
  var videoId: String?
  var type: VideoType?
  var play: Bool
  var seek: Double
  
  enum CodingKeys: String, CodingKey {
    case id
    case videoId
    case type
    case play
    case seek
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(String.self, forKey: .id)
    videoId = try values.decodeIfPresent(String.self, forKey: .videoId)
    type = try values.decodeIfPresent(VideoType.self, forKey: .type)
    play = try values.decodeIfPresent(Bool.self, forKey: .play) ?? false
    seek = try values.decodeIfPresent(Double.self, forKey: .seek) ?? 0
  }
  
  public init(videoId: String,
              type: VideoType = .youtube,
              play: Bool = false,
              seek: Double = 0) {
    
    self.id = UUID().uuidString
    self.videoId = videoId
    self.type = type
    self.play = play
    self.seek = seek
  }
}
