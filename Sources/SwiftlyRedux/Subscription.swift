//  Copyright © 2020 William Vabrinskas. All rights reserved.
import Foundation
import Combine

open protocol Subscription {
  associatedtype TModule: Module
  var module: TModule { get }
  
  func obj<TType>() -> TType?
  func publisher<TType>() -> Published<TType?>.Publisher
}

open extension Subscription {
  open func obj<TType>() -> TType? {
    return self.module.object as? TType
  }
  
  open func publisher<TType>() -> Published<TType?>.Publisher {
    let randomObj: TType? = nil
    var pub = Published.init(initialValue: randomObj)
    let obj = self.module
    return obj.objectPublisher as? Published<TType?>.Publisher ?? pub.projectedValue
  }
}
