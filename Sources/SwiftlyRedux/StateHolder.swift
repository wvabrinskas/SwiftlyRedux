//
//  File.swift
//  
//
//  Created by William Vabrinskas on 10/11/21.
//

import Foundation



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
  
  func object<TType, TSub: StateSubscription>(type: TSub.Type) -> TType?
  func subscribe<TType, TSub: StateSubscription>(type: TSub.Type) -> Published<TType?>.Publisher
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
  
  func subscribe<TType, TSub>(type: TSub.Type) -> Published<TType?>.Publisher where TSub : StateSubscription {
    let sub = self.getSubscription(type: type)
    
    guard let pub = sub?.module.objectPublisher as? Published<TType?>.Publisher else {
      fatalError("No publisher available for type: \(type)")
    }
    
    return pub
  }
  
  func object<TType, TSub>(type: TSub.Type) -> TType? where TSub : StateSubscription {
    let sub = self.getSubscription(type: type)

    return sub?.module.object as? TType
  }
  
  // MARK: Private
  
  func getSubscription<TSub>(type: TSub.Type) -> TSub? where TSub : StateSubscription {
    let key = "\(TSub.self)"
    let sub = self.subscriptions[key]?.subcription as? TSub
    return sub
  }
  
}
