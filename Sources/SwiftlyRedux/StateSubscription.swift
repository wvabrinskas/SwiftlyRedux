//  Copyright © 2020 William Vabrinskas. All rights reserved.
import Foundation
import Combine

public protocol StateSubscription {
  associatedtype TModule: Module
  var module: TModule { get }
  
  func obj(id: TModule.Sub.SubID) -> TModule.Sub.ObjectType?
  func publisher(id: TModule.Sub.SubID) -> AnyPublisher<TModule.Sub.ObjectType, Error>
}

public extension StateSubscription {
  func obj(id: TModule.Sub.SubID) -> TModule.Sub.ObjectType? {
    return self.module.getSubject(id:id) as? Self.TModule.Sub.ObjectType
  }
  
  func publisher(id: TModule.Sub.SubID) -> AnyPublisher<TModule.Sub.ObjectType, Error>? {
    let obj = self.module
    return obj.getSubject(id: id)?.objectPublisher
  }
}
