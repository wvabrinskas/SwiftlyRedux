//
//  Subscription.swift
//
//  Created by William Vabrinskas on 9/25/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import Combine

protocol Subscription {
  associatedtype TModule: Module
  var module: TModule { get }
  
  func obj<TType>() -> TType?
  func publisher<TType>() -> Published<TType?>.Publisher
}

extension Subscription {
  func obj<TType>() -> TType? {
    return self.module.object as? TType
  }
  
  func publisher<TType>() -> Published<TType?>.Publisher {
    let randomObj: TType? = nil
    var pub = Published.init(initialValue: randomObj)
    let obj = self.module
    return obj.objectPublisher as? Published<TType?>.Publisher ?? pub.projectedValue
  }
}

struct AuthSubscription: Subscription {
  typealias TModule = AuthModule
  var module: AuthModule = AuthModule()
}

struct MediaSubscription: Subscription {
  typealias TModule = MediaModule
  var module: MediaModule = MediaModule()
}

struct SessionSubscription: Subscription {
  typealias TModule = SessionModule
  var module: SessionModule = SessionModule()
}

struct FeedSubscription: Subscription {
  typealias TModule = FeedModule
  var module: FeedModule = FeedModule()
}
