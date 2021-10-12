//
//  File.swift
//  
//
//  Created by William Vabrinskas on 10/11/21.
//

import Foundation

public protocol StateHolder: AnyObject {
  var subscriptions: Set<AnyHashable> { get set }
  
  func addSubscription<TSub: StateSubscription>(sub: TSub)
  func removeSubscription<TSub: StateSubscription>(sub: TSub)
  func object<TType, TSub: StateSubscription>(type: TSub.Type) -> TType?
  func subscribe<TType, TSub: StateSubscription>(type: TSub.Type) -> Published<TType?>.Publisher
}

public extension StateHolder {
  func addSubscription<TSub>(sub: TSub) where TSub: StateSubscription {
    let _ = self.subscriptions.insert(sub)
  }
  
  func removeSubscription<TSub>(sub: TSub) where TSub: StateSubscription {
    let _ = self.subscriptions.remove(sub)
  }
  
  func subscribe<TType, TSub>(type: TSub.Type) -> Published<TType?>.Publisher where TSub : StateSubscription {
    let sub = self.subscriptions.first(where: { $0 is TSub.Type }) as? TSub
    
    guard let pub = sub?.module.objectPublisher as? Published<TType?>.Publisher else {
      fatalError("No publisher available for type: \(type)")
    }
    
    return pub
  }
  
  func object<TType, TSub>(type: TSub) -> TType? where TSub : StateSubscription {
    type.module.object as? TType
  }
  
}
