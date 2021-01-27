//
//  Media.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/23/21.
//

import Foundation

public enum MediaType: String, Codable {
  case video, photo
}

public struct Media: Codable, Identifiable, Equatable {
  public var id: String = UUID().uuidString
  public var url: String
  public var type: MediaType = .photo
  public var uploadDate: Date = Date()
  public var description: String = ""
  public var comments: [String] = []
  public var feedRefId: String

  enum CodingKeys: String, CodingKey {
    case id
    case url
    case type
    case uploadDate
    case description
    case comments
    case feedRefId
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
    type = try values.decodeIfPresent(MediaType.self, forKey: .type) ?? .photo
    uploadDate = try values.decodeIfPresent(Date.self, forKey: .uploadDate) ?? Date()
    description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    comments = try values.decodeIfPresent([String].self, forKey: .comments) ?? []
    feedRefId = try values.decode(String.self, forKey: .feedRefId)
  }
  
  public init(id: String = UUID().uuidString,
              url: String,
              type: MediaType,
              uploadDate: Date = Date(),
              description: String = "",
              comments: [String] = [],
              feedRefId: String) {
    self.id = id
    self.url = url
    self.type = type
    self.uploadDate = uploadDate
    self.description = description
    self.comments = comments
    self.feedRefId = feedRefId
  }
}
