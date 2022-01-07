import XCTest
import Combine
@testable import SwiftlyRedux


final class SwiftlyReduxTests: XCTestCase {
  let state = SwiftlyStateHolder()
  var set: Set<AnyCancellable> = []
  
  override func setUp() {
    self.set.removeAll()
  }
  
  func testSettingDataWithNoSubscription() {
    let originalObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    XCTAssert(originalObject == TestConfig.initialData)
    
    state.addData()
    
    let newObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    XCTAssert(newObject == TestConfig.expectedData)
  }
  
  func testSettingDataWithSubscription() {
    let publisher: AnyPublisher<[String]?, Error>? = self.state.subscribe(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    let originalObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)

    XCTAssert(originalObject == TestConfig.initialData)

    let expectation = XCTestExpectation()
    
    var returnObject: [String]?
    var returnError: Error?
    
    publisher?
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
    
    wait(for: [expectation], timeout: TestConfig.expectationTimeout)
    
    XCTAssertNotNil(returnObject, "Object was never set meaning there was an error: \(returnError?.localizedDescription ?? "")")
    XCTAssert(returnObject == TestConfig.expectedData)
  }
  
  func testGenricCompletionFromPublisherSuccess() {
    let publisher: AnyPublisher<[String]?, Error>? = self.state.subscribe(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    
    let originalObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)

    XCTAssert(originalObject == TestConfig.initialData)

    let expectation = XCTestExpectation()
    
    var success: Bool = false
    
    publisher?
      .sink(receiveCompletion: { error in
        switch error {
        case .failure:
          break
        case .finished:
          success = true
        }
        expectation.fulfill()
      }, receiveValue: { newObject in
        expectation.fulfill()
      })
      .store(in: &self.set)
    
    
    state.sendSubscriptionCompletion(type: .finished, identifier: .data)
    
    wait(for: [expectation], timeout: TestConfig.expectationTimeout)

    XCTAssert(success == true)
  }
  
}
