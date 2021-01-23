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
  public var url: String?
  public var type: MediaType
  public var uploadDate: Date = Date()
}
