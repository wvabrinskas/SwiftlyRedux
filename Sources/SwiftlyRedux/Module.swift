
//  Copyright © 2020 William Vabrinskas. All rights reserved.

import Foundation
import Combine

public protocol Module: ObservableObject {
  associatedtype ObjectType

  var object: ObjectType? { get set }
  var objectSubject: PassthroughSubject<ObjectType?, Error> { get }
  var objectPublisher: AnyPublisher<ObjectType?, Error> { get }
}

public extension Module {
  var objectPublisher: AnyPublisher<ObjectType?, Error> {
    return objectSubject.eraseToAnyPublisher()
  }
}
