//  Copyright © 2020 William Vabrinskas. All rights reserved.
import Foundation
import Combine

public protocol StateSubscription: Hashable {
  associatedtype TModule: Module
  var module: TModule { get }
  var id: UUID { get set }
  
  func obj<TType>() -> TType?
  func publisher<TType>() -> Published<TType?>.Publisher
}

public extension StateSubscription {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
  
  func obj<TType>() -> TType? {
    return self.module.object as? TType
  }
  
  func publisher<TType>() -> Published<TType?>.Publisher {
    let randomObj: TType? = nil
    var pub = Published.init(initialValue: randomObj)
    let obj = self.module
    return obj.objectPublisher as? Published<TType?>.Publisher ?? pub.projectedValue
  }
}
