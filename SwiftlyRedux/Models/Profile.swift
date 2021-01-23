//
//  Profile.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

struct PreProfile {
  var isRealtor: Bool = false
  var firstName: String
  var lastName: String
  var profileImage: String? = nil
  var homes: [String] = []
}

struct Profile: Codable {
  var userId: String
  var isRealtor: Bool
  var firstName: String
  var lastName: String
  var profileImage: String?
  var homes: [String]
  
  enum CodingKeys: String, CodingKey {
    case userId
    case isRealtor
    case firstName
    case lastName
    case profileImage
    case homes
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    userId = try values.decode(String.self, forKey: .userId)
    isRealtor = try values.decodeIfPresent(Bool.self, forKey: .isRealtor) ?? false
    firstName = try values.decodeIfPresent(String.self, forKey: .firstName) ?? ""
    lastName = try values.decodeIfPresent(String.self, forKey: .lastName) ?? ""
    profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
    homes = try values.decodeIfPresent([String].self, forKey: .homes) ?? []
  }
  
  public init(id: String, preProfile: PreProfile) {
    self.userId = id
    self.isRealtor = preProfile.isRealtor
    self.firstName = preProfile.firstName
    self.lastName = preProfile.lastName
    self.profileImage = preProfile.profileImage
    self.homes = preProfile.homes
  }
  
  public init(userId: String,
              isRealtor: Bool = false,
              firstName: String,
              lastName: String,
              profileImage: String? = nil,
              homes: [String] = []) {
    
    self.userId = userId
    self.isRealtor = isRealtor
    self.firstName = firstName
    self.lastName = lastName
    self.profileImage = profileImage
    self.homes = homes
  }
  
  mutating func addHome(_ home: String) {
    self.homes.append(home)
  }
}
