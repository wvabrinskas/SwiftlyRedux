
//  Copyright © 2020 William Vabrinskas. All rights reserved.

import Foundation
import Combine

public protocol Module: ObservableObject, Hashable {
  associatedtype ObjectType
  var id: UUID { get set }
  //Should be @Published in implementation, no way to do this yet in a protocol
  var object: ObjectType? { get set }
  var objectPublisher: Published<ObjectType?>.Publisher { get }
}

public extension Module {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}
