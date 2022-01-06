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
  
  func object<TSub: StateSubscription>(type: TSub.Type, id: TSub.TModule.Sub.SubID) -> TSub.TModule.Sub.ObjectType?
  func subscribe<TSub: StateSubscription>(type: TSub.Type, id: TSub.TModule.Sub.SubID) -> AnyPublisher<TSub.TModule.Sub.ObjectType?, Error>
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
  
  func subscribe<TSub: StateSubscription>(type: TSub.Type, id: TSub.TModule.Sub.SubID) -> AnyPublisher<TSub.TModule.Sub.ObjectType?, Error> {
    let sub = self.getSubscription(type: type)
    
    guard let pub = sub?.module.getSubject(id: id)?.objectPublisher as? AnyPublisher<TSub.TModule.Sub.ObjectType?, Error> else {
      fatalError("No publisher available for type: \(type)")
    }
    
    return pub
  }
  
  func object<TSub: StateSubscription>(type: TSub.Type, id: TSub.TModule.Sub.SubID) -> TSub.TModule.Sub.ObjectType? {
    let sub = self.getSubscription(type: type)
    return sub?.obj(id: id)
  }
    
  func getSubscription<TSub>(type: TSub.Type) -> TSub? where TSub : StateSubscription {
    let key = "\(TSub.self)"
    let sub = self.subscriptions[key]?.subcription as? TSub
    return sub
  }
  
}
