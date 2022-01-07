//  Copyright © 2020 William Vabrinskas. All rights reserved.
import Foundation
import Combine

public protocol StateSubscription {
  associatedtype TModule: Module
  var module: TModule { get }
  
  func obj<TID: SubjectIdentifier, TValue>(id: TID) -> TValue?
  func publisher<TID: SubjectIdentifier, TValue>(id: TID) -> AnyPublisher<TValue?, Error>?
}

public extension StateSubscription {
  func obj<TID: SubjectIdentifier, TValue>(id: TID) -> TValue? {
    let subject: SubjectHolder<TValue, TID>? = self.module.getSubject(id: id)
    return subject?.object
  }
  
  func publisher<TID: SubjectIdentifier, TValue>(id: TID) -> AnyPublisher<TValue?, Error>? {
    let obj = self.module
    return obj.getSubject(id: id)?.objectPublisher
  }
}
