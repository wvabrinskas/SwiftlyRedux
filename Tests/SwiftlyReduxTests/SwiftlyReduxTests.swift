import XCTest
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

final class SwiftlyReduxTests: XCTestCase {
  let state = SwiftlyStateHolder()
  var set: Set<AnyCancellable> = []
  
  func testSettingDataWithNoSubscription() {
    let originalObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    XCTAssert(originalObject == TestData.initialData)
    
    state.addData()
    
    let newObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    XCTAssert(newObject == TestData.expectedData)
  }
  
  func testSettingDataWithSubscription() {
    let publisher: AnyPublisher<[String]?, Error>? = self.state.subscribe(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    let originalObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)

    XCTAssert(originalObject == TestData.initialData)

    let expectation = XCTestExpectation()
    
    var returnObject: [String]?
    var returnError: Error?
    
    publisher?
      .subscribe(on: DispatchQueue.global())
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { error in
        switch error {
        case .failure(let error):
          returnError = error
        case .finished:
          break
        }
        expectation.fulfill()
      }, receiveValue: { newObject in
        expectation.fulfill()
        returnObject = newObject
      })
      .store(in: &self.set)
    
    state.addData()
    
    wait(for: [expectation], timeout: 10)
    
    XCTAssertNotNil(returnObject, "Object was never set meaning there was an error: \(returnError?.localizedDescription ?? "")")
    XCTAssert(returnObject == TestData.expectedData)
  }
  
}
