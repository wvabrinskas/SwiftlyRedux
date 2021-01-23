//
//  Feed.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/23/21.
//

import Foundation

struct Feed: Codable {
  var id: String = UUID().uuidString
  var media: [String] = [] //list of string ids that point to the media objects
}
