//
//  File.swift
//  
//
//  Created by William Vabrinskas on 1/6/22.
//

import Foundation
import Combine
@testable import SwiftlyRedux

struct TestData {
  static let initialWord = "init"
  static let wordAdding = "test"
  static var initialData: [String] {
    return [Self.initialWord]
  }
  static var expectedData: [String] {
    return [Self.initialWord, Self.wordAdding]
  }
}

final class SwiftlyModule: Module {

  enum SubjectIdentifiers: Int, SubjectIdentifier {

    case data
    
    var stringValue: String {
      return "\(self.rawValue)"
    }
    
  }
  
  var subjects: [String : AnySubject] = [:]
  
  init() {
    self.addSubject(TestData.initialData, identifier: SubjectIdentifiers.data)
  }
  
  func addData() {
    var newData: [String]? = self.getSubject(id: SubjectIdentifiers.data)?.object
    newData?.append(TestData.wordAdding)
    self.updateSubject(value: newData, identifier: SubjectIdentifiers.data)
  }
}

struct SwiftlySubscription: StateSubscription, SwiftlySubscriptionDescription {
  
  typealias TModule = SwiftlyModule
  var module: SwiftlyModule = SwiftlyModule()
  
  func addData() {
    self.module.addData()
  }
}

protocol SwiftlySubscriptionDescription {
  func addData()
}

final class SwiftlyStateHolder: StateHolder, SwiftlySubscriptionDescription {
  var subscriptions: [String : AnySubscription] = [:]
  
  init() {
    self.addSubscription(sub: SwiftlySubscription())
  }
    
  func addData() {
    self.getSubscription(type: SwiftlySubscription.self)?.addData()
  }
}
