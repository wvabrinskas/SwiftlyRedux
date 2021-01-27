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
  
  enum CodingKeys: String, CodingKey {
    case id
    case comment
    case postedDate
    case poster
    case mediaRefId
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    comment = try values.decodeIfPresent(String.self, forKey: .comment) ?? ""
    postedDate = try values.decodeIfPresent(Date.self, forKey: .postedDate) ?? Date()
    poster = try values.decodeIfPresent(String.self, forKey: .poster) ?? ""
    mediaRefId = try values.decodeIfPresent(String.self, forKey: .mediaRefId) ?? ""
  }
  
  public init(id: String = UUID().uuidString,
              comment: String = "",
              postedDate: Date = Date(),
              poster: String,
              mediaRefId: String) {
    self.id = id
    self.comment = comment
    self.postedDate = postedDate
    self.poster = poster
    self.mediaRefId = mediaRefId
  }
}
