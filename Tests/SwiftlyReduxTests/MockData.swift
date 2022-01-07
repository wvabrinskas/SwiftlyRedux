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
  static let nullInitialData: [String]? = nil
  static let differentDataType: Int = 10
  
  static var initialData: [String] {
    return [Self.initialWord]
  }
  
  static var expectedData: [String] {
    return [Self.initialWord, Self.wordAdding]
  }
  
  static var expectedNullDataAddition: [String] {
    return [Self.wordAdding]
  }
  
  static var expectationTimeout: Double = 30
}

final class SwiftlyModule: Module {

  enum SubjectIdentifiers: String, SubjectIdentifier {

    case data
    case nullData
    case differentDataType
  
    var stringValue: String {
      return "\(self.rawValue)"
    }
  }
  
  var subjects: [String : AnySubjectHolder] = [:]
  
  init() {
    self.addSubject(TestConfig.initialData, identifier: SubjectIdentifiers.data)
    self.addSubject(TestConfig.nullInitialData, identifier: SubjectIdentifiers.nullData)
    self.addSubject(TestConfig.differentDataType, identifier: SubjectIdentifiers.differentDataType)
  }
  
  func addData() {
    var newData: [String] = self.getSubject(id: SubjectIdentifiers.data)?.object ?? []
    newData.append(TestConfig.wordAdding)
    self.updateSubject(value: newData, identifier: SubjectIdentifiers.data)
  }
  
  func addToNullData() {
    var newData: [String]? = self.getSubject(id: SubjectIdentifiers.nullData)?.object
    newData = newData == nil ? [] : newData
    newData?.append(TestConfig.wordAdding)
    self.updateSubject(value: newData, identifier: SubjectIdentifiers.nullData)
  }
  
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>,
                                  identifier: SubjectIdentifiers) {
    switch identifier {
    case .data:
      let subject: SubjectHolder<[String], SubjectIdentifiers>? = self.getSubject(id: identifier)
      subject?.objectSubject.send(completion: type)
    case .nullData:
      let subject: SubjectHolder<[String]?, SubjectIdentifiers>? = self.getSubject(id: identifier)
      subject?.objectSubject.send(completion: type)
    case .differentDataType:
      let subject: SubjectHolder<Int, SubjectIdentifiers>? = self.getSubject(id: identifier)
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
  
  func addToNullData() {
    self.module.addToNullData()
  }
  
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>, identifier: SwiftlyModule.SubjectIdentifiers) {
    self.module.sendSubscriptionCompletion(type: type, identifier: identifier)
  }

}

protocol SwiftlySubscriptionDescription {
  func addData()
  func addToNullData()
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>, identifier: SwiftlyModule.SubjectIdentifiers)
}

final class SwiftlyStateHolder: StateHolder, SwiftlySubscriptionDescription {
  var subscriptions: [String : AnySubscription] = [:]
  
  init() {
    self.addSubscription(sub: SwiftlySubscription())
  }
    
  func addToNullData() {
    self.getSubscription(type: SwiftlySubscription.self)?.addToNullData()
  }
  
  func addData() {
    self.getSubscription(type: SwiftlySubscription.self)?.addData()
  }
  
  func sendSubscriptionCompletion(type: Subscribers.Completion<Error>, identifier: SwiftlyModule.SubjectIdentifiers) {
    self.getSubscription(type: SwiftlySubscription.self)?.sendSubscriptionCompletion(type: type, identifier: identifier)
  }
}
