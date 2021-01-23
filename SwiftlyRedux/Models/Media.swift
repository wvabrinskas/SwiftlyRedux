//
//  Media.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/23/21.
//

import Foundation

public protocol Media: Codable, Identifiable {
  var id: UUID { get }
  var url: String? { get set }
}

public extension Media {
  var id: UUID {
    return UUID()
  }
}
