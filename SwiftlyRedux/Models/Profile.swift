//
//  Profile.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

struct PreProfile {
  var firstName: String
  var lastName: String
  var profileImage: String? = nil
}

struct Profile: Codable {
  var userId: String
  var firstName: String
  var lastName: String
  var profileImage: String?
  var media: [String]
  
  enum CodingKeys: String, CodingKey {
    case userId
    case firstName
    case lastName
    case profileImage
    case media
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    userId = try values.decode(String.self, forKey: .userId)
    firstName = try values.decodeIfPresent(String.self, forKey: .firstName) ?? ""
    lastName = try values.decodeIfPresent(String.self, forKey: .lastName) ?? ""
    profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
    media = try values.decodeIfPresent([String].self, forKey: .media) ?? []
  }
  
  public init(id: String, preProfile: PreProfile) {
    self.userId = id
    self.firstName = preProfile.firstName
    self.lastName = preProfile.lastName
    self.profileImage = preProfile.profileImage
    self.media = []
  }
  
  public init(userId: String,
              firstName: String,
              lastName: String,
              profileImage: String? = nil,
              media: [String] = []) {
    
    self.userId = userId
    self.firstName = firstName
    self.lastName = lastName
    self.profileImage = profileImage
    self.media = media
  }
}
