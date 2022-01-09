//  Copyright © 2020 William Vabrinskas. All rights reserved.
import Foundation
import Combine

/// A proxy object that manages the connection between the `StateHolder` and a given `Module`
public protocol StateSubscription {
  associatedtype TModule: Module
  
  /// `Module` that this subscription is providing to the state
  var module: TModule { get }
  
  /// Object from the `SubjectObservable` given by the `SubjectIdentifier`
  /// - Returns: The object of type `TValue`
  func obj<TID: SubjectIdentifier, TValue>(id: TID) -> TValue?
  
  /// Publisher of type `AnyPublisher` from the `SubjectObservable` given by the `SubjectIdentifier`
  /// - Returns: The publisher of type `AnyPublisher<TValue, Error>?`
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
