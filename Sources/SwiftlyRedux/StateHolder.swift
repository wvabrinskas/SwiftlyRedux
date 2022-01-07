//
//  File.swift
//  
//
//  Created by William Vabrinskas on 10/11/21.
//

import Foundation
import Combine

//for type erasure
public struct AnySubscription {
  internal var subcription: Any
  
  internal init<T: StateSubscription>(_ sub: T) {
    self.subcription = sub
  }
}

public protocol StateHolder: AnyObject {
  var subscriptions: [String: AnySubscription] { get set }
  
  func addSubscription<TSub: StateSubscription>(sub: TSub)
  func removeSubscription<TSub: StateSubscription>(sub: TSub)
  func getSubscription<TSub: StateSubscription>(type: TSub.Type) -> TSub?
  
  func object<TSub: StateSubscription, TReturn, TSubID: SubjectIdentifier>(type: TSub.Type,
                                                                           id: TSubID) -> TReturn?
  
  func subscribe<TSub: StateSubscription, TReturn, TSubID: SubjectIdentifier>(type: TSub.Type,
                                                                              id: TSubID) -> AnyPublisher<TReturn?, Error>
}

public extension StateHolder {
  func addSubscription<TSub>(sub: TSub) where TSub: StateSubscription {
    let key = "\(TSub.self)"
    self.subscriptions[key] = AnySubscription(sub)
  }
  
  func removeSubscription<TSub>(sub: TSub) where TSub: StateSubscription {
    let key = "\(TSub.self)"
    let _ = self.subscriptions.removeValue(forKey: key)
  }
  
  func subscribe<TSub: StateSubscription, TID: SubjectIdentifier, TValue>(type: TSub.Type,
                                                                          id: TID) -> AnyPublisher<TValue, Error> {
    let stateSubscription = self.getSubscription(type: type)
    let subject: SubjectHolder<TValue, TID>? = stateSubscription?.module.getSubject(id: id)
    
    guard let pub = subject?.objectPublisher else {
      fatalError("No publisher available for type: \(type) - \(TValue.self) subjects in state: \(stateSubscription?.module.subjects)")
    }
    
    return pub
  }
  
  func object<TSub: StateSubscription, TReturn, TSubID: SubjectIdentifier>(type: TSub.Type,
                                                                           id: TSubID) -> TReturn? {
    let sub = self.getSubscription(type: type)
    return sub?.obj(id: id)
  }
  
  func getSubscription<TSub>(type: TSub.Type) -> TSub? where TSub : StateSubscription {
    let key = "\(TSub.self)"
    let sub = self.subscriptions[key]?.subcription as? TSub
    return sub
  }
}
