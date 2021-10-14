//  Copyright © 2020 William Vabrinskas. All rights reserved.
import Foundation
import Combine

public protocol StateSubscription {
  associatedtype TModule: Module
  var module: TModule { get }
  
  func obj<TType>() -> TType?
  func publisher<TType>() -> AnyPublisher<TType?, Error>?
  func errorPublisher() -> Published<Error>.Publisher

}

public extension StateSubscription {
  func obj<TType>() -> TType? {
    return self.module.object as? TType
  }
  
  func publisher<TType>() -> AnyPublisher<TType?, Error>? {
    let obj = self.module
    return obj.objectPublisher as? AnyPublisher<TType?, Error>
  }
}
