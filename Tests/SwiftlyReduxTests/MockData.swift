//
//  File.swift
//  
//
//  Created by William Vabrinskas on 1/6/22.
//

import Foundation
import Combine
@testable import SwiftlyRedux

struct TestConfig {
  static let initialWord = "init"
  static let wordAdding = "test"
  static var initialData: [String] {
    return [Self.initialWord]
  }
  static var expectedData: [String] {
    return [Self.initialWord, Self.wordAdding]
  }
  static var expectationTimeout: Double = 30
}

final class SwiftlyModule: Module {

  enum SubjectIdentifiers: Int, SubjectIdentifier {

    case data
  
    var stringValue: String {
      return "\(self.rawValue)"
    }
  }
  
  var subjects: [String : AnySubjectHolder] = [:]
  
  init() {
    self.addSubject(TestConfig.initialData, identifier: SubjectIdentifiers.data)
  }
  
  func addData() {
    var newData: [String]? = self.getSubject(id: SubjectIdentifiers.data)?.object
    newData?.append(TestConfig.wordAdding)
    self.updateSubject(value: newData, identifier: SubjectIdentifiers.data)
  }
  
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>,
                                  identifier: SubjectIdentifiers) {
    switch identifier {
    case .data:
      let subject: SubjectHolder<[String], SubjectIdentifiers>? = self.getSubject(id: identifier)
      subject?.objectSubject.send(completion: type)
    }
  }
}

struct SwiftlySubscription: StateSubscription, SwiftlySubscriptionDescription {
  typealias TModule = SwiftlyModule
  var module: SwiftlyModule = SwiftlyModule()
  
  func addData() {
    self.module.addData()
  }
  
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>, identifier: SwiftlyModule.SubjectIdentifiers) {
    self.module.sendSubscriptionCompletion(type: type, identifier: identifier)
  }

}

protocol SwiftlySubscriptionDescription {
  func addData()
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>, identifier: SwiftlyModule.SubjectIdentifiers)
}

final class SwiftlyStateHolder: StateHolder, SwiftlySubscriptionDescription {
  var subscriptions: [String : AnySubscription] = [:]
  
  init() {
    self.addSubscription(sub: SwiftlySubscription())
  }
    
  func addData() {
    self.getSubscription(type: SwiftlySubscription.self)?.addData()
  }
  
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>, identifier: SwiftlyModule.SubjectIdentifiers) {
    self.getSubscription(type: SwiftlySubscription.self)?.sendSubscriptionCompletion(type: type, identifier: identifier)
  }
}
