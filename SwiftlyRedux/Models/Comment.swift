//
//  Comment.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/27/21.
//

import Foundation

struct Comment: Codable, Equatable {
  var id: String = UUID().uuidString
  var comment: String
  var postedDate: Date = Date()
  var poster: String
  var mediaRefId: String
  var posterImage: String?
  var posterUsername: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case comment
    case postedDate
    case poster
    case mediaRefId
    case posterImage
    case posterUsername
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    comment = try values.decodeIfPresent(String.self, forKey: .comment) ?? ""
    postedDate = try values.decodeIfPresent(Date.self, forKey: .postedDate) ?? Date()
    poster = try values.decodeIfPresent(String.self, forKey: .poster) ?? ""
    mediaRefId = try values.decodeIfPresent(String.self, forKey: .mediaRefId) ?? ""
    posterImage = try values.decodeIfPresent(String.self, forKey: .posterImage)
    posterUsername = try values.decodeIfPresent(String.self, forKey: .posterUsername) ?? ""
  }
  
  public init(id: String = UUID().uuidString,
              comment: String = "",
              postedDate: Date = Date(),
              poster: String,
              mediaRefId: String,
              posterImage: String?,
              posterUsername: String) {
    self.id = id
    self.comment = comment
    self.postedDate = postedDate
    self.poster = poster
    self.mediaRefId = mediaRefId
    self.posterImage = posterImage
    self.posterUsername = posterUsername
  }
}
