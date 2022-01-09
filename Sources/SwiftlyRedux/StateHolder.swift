//
//  File.swift
//  
//
//  Created by William Vabrinskas on 10/11/21.
//

import Foundation
import Combine

/// Type erased `StateSubscription`
public struct AnySubscription {
  internal var subcription: Any
  
  internal init<T: StateSubscription>(_ sub: T) {
    self.subcription = sub
  }
}

/// The class that holds the one source of truth for it's underlying subscriptions. Manages state.
public protocol StateHolder: AnyObject {
  
  /// Current subscriptions that the state subscribes to
  var subscriptions: [String: AnySubscription] { get set }
  
  /// Adds a subscription to the state
  func addSubscription<TSub: StateSubscription>(sub: TSub)
  
  /// Removes a subscription from the state
  func removeSubscription<TSub: StateSubscription>(sub: TSub)
  
  /// Get a subscription by that `StateSubscription`s type.
  /// - Returns: the `StateDescription` of type provided.
  func getSubscription<TSub: StateSubscription>(type: TSub.Type) -> TSub?
  
  /// The object of type `TReturn` from the `StateSubscrition`'s `Module` given by the provided `SubjectIdentifier`
  /// - Returns: The object of type `TReturn` held by the `SubjectObservable` given by the `SubjectIdentifier`
  func object<TSub: StateSubscription, TReturn, TSubID: SubjectIdentifier>(type: TSub.Type,
                                                                           id: TSubID) -> TReturn?
  
  /// The `AnyPublisher` returning type `TReturn` from the `StateSubscrition`'s `Module` given by the provided `SubjectIdentifier`
  /// - Returns: The `AnyPublisher` returning type `TReturn` held by the `SubjectObservable` given by the `SubjectIdentifier`
  func subscribe<TSub: StateSubscription, TReturn, TSubID: SubjectIdentifier>(type: TSub.Type,
                                                                              id: TSubID) -> AnyPublisher<TReturn?, Error>?
}

public extension StateHolder {
  /// Adds a subscription to the state
  func addSubscription<TSub>(sub: TSub) where TSub: StateSubscription {
    let key = "\(TSub.self)"
    self.subscriptions[key] = AnySubscription(sub)
  }
  
  /// Removes a subscription from the state
  func removeSubscription<TSub>(sub: TSub) where TSub: StateSubscription {
    let key = "\(TSub.self)"
    let _ = self.subscriptions.removeValue(forKey: key)
  }

  /// The `AnyPublisher` returning type `TReturn` from the `StateSubscrition`'s `Module` given by the provided `SubjectIdentifier`
  /// - Returns: The `AnyPublisher` returning type `TReturn` held by the `SubjectObservable` given by the `SubjectIdentifier`
  func subscribe<TSub: StateSubscription, TID: SubjectIdentifier, TValue>(type: TSub.Type,
                                                                          id: TID) -> AnyPublisher<TValue, Error>? {
    let stateSubscription = self.getSubscription(type: type)
    let subject: SubjectHolder<TValue, TID>? = stateSubscription?.module.getSubject(id: id)
    
    guard let pub = subject?.objectPublisher else {
      print("SwiftlyRedux Fatal Error: Could not get publisher as the value you provided for the publisher doesn't match the type for the provided subject id. It's possible that you're expecting a non-optional value but passing in an optional value type to the generic typed value parameter.")
      print("SwiftlyRedux Fatal Error: publisher available for type: \(type) - \(TValue.self) subjects in state: \(String(describing: stateSubscription?.module.subjects))")
      return nil
    }
    
    return pub
  }
  
  /// The object of type `TReturn` from the `StateSubscrition`'s `Module` given by the provided `SubjectIdentifier`
  /// - Returns: The object of type `TReturn` held by the `SubjectObservable` given by the `SubjectIdentifier`
  func object<TSub: StateSubscription, TReturn, TSubID: SubjectIdentifier>(type: TSub.Type,
                                                                           id: TSubID) -> TReturn? {
    let sub = self.getSubscription(type: type)
    return sub?.obj(id: id)
  }
  
  /// Get a subscription by that `StateSubscription`s type.
  /// - Returns: the `StateDescription` of type provided.
  func getSubscription<TSub>(type: TSub.Type) -> TSub? where TSub : StateSubscription {
    let key = "\(TSub.self)"
    let sub = self.subscriptions[key]?.subcription as? TSub
    return sub
  }
}
