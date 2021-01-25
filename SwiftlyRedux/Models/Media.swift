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

public struct Media: Codable, Identifiable {
  public var id: String = UUID().uuidString
  public var url: String
  public var type: MediaType = .photo
  public var uploadDate: Date = Date()
  public var description: String = ""
  
  enum CodingKeys: String, CodingKey {
    case id
    case url
    case type
    case uploadDate
    case description
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
    type = try values.decodeIfPresent(MediaType.self, forKey: .type) ?? .photo
    uploadDate = try values.decodeIfPresent(Date.self, forKey: .uploadDate) ?? Date()
    description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
  }
}
