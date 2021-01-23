//
//  RealtimeHome.swift
//  Homes
//
//  Created by William Vabrinskas on 9/11/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

public struct RealtimeSession: Codable {
  var id: String
  var members: [String]
  var playVideo: Bool
  
  enum CodingKeys: String, CodingKey {
    case id
    case members
    case playVideo
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(String.self, forKey: .id)
    members = try values.decodeIfPresent([String].self, forKey: .members) ?? []
    playVideo = try values.decodeIfPresent(Bool.self, forKey: .playVideo) ?? false
  }
  
  public init(id: String,
              members: [String] = [],
              homes: [String] = [],
              homeIndex: Int = 0,
              playVideo: Bool = false) {
    self.id = id
    self.members = members
    self.playVideo = playVideo
  }
}
