//
//  File.swift
//  
//
//  Created by William Vabrinskas on 10/11/21.
//

import Foundation

public protocol StateHolder {
  func object<TType, TSub: StateSubscription>(type: TSub) -> TType?
  func subscribe<TType, TSub: StateSubscription>(type: TSub) -> Published<TType?>.Publisher
}

extension StateHolder {
  func subscribe<TType, TSub>(type: TSub) -> Published<TType?>.Publisher where TSub : StateSubscription {
    guard let pub = type.module.objectPublisher as? Published<TType?>.Publisher else {
      fatalError("No publisher available for type: \(type)")
    }
    
    return pub
  }
  
  func object<TType, TSub>(type: TSub) -> TType? where TSub : StateSubscription {
    type.module.object as? TType
  }
  
}
