
//  Copyright © 2020 William Vabrinskas. All rights reserved.

import Foundation
import Combine

public protocol Module: ObservableObject, Hashable {
  associatedtype ObjectType
  //Should be @Published in implementation, no way to do this yet in a protocol
  var object: ObjectType? { get set }
  var objectPublisher: Published<ObjectType?>.Publisher { get }
}

