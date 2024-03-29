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
    let publisher: AnyPublisher<[String], Error>? = self.state.subscribe(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)
    
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
    var success: Bool = false
    let expectation = XCTestExpectation()
    
    let originalObject: [String]? = self.state.object(type: SwiftlySubscription.self, id: SwiftlyModule.SubjectIdentifiers.data)

    XCTAssert(originalObject == TestConfig.initialData)
    
    self.state.on(id: SwiftlyModule.SubjectIdentifiers.data,
                  in: SwiftlySubscription.self) { error in
      
      XCTAssert(error == nil, error?.localizedDescription ?? "Some Error")
      success = true
      expectation.fulfill()
    } recieve: { (value: [String]) in
      success = true
      expectation.fulfill()
    }

    state.sendSubscriptionCompletion(type: .finished, identifier: .data)
    
    wait(for: [expectation], timeout: TestConfig.expectationTimeout)

    XCTAssert(success == true)
  }
  
  func testWithNullSubjectObject() {
    let publisher: AnyPublisher<[String]?, Error>? = self.state.subscribe(type: SwiftlySubscription.self,
                                                                          id: SwiftlyModule.SubjectIdentifiers.nullData)
    XCTAssert(publisher != nil)
  }
  
  func testWithNullSubjectUpdatesData() {
    let publisher: AnyPublisher<[String]?, Error>? = self.state.subscribe(type: SwiftlySubscription.self,
                                                                          id: SwiftlyModule.SubjectIdentifiers.nullData)
    
    let originalObject: [String]? = self.state.object(type: SwiftlySubscription.self,
                                                      id: SwiftlyModule.SubjectIdentifiers.nullData)

    XCTAssert(originalObject == TestConfig.nullInitialData)
    
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
    
    state.addToNullData()
    
    wait(for: [expectation], timeout: TestConfig.expectationTimeout)
    
    XCTAssertNotNil(returnObject, "Object was never set meaning there was an error: \(returnError?.localizedDescription ?? "")")
    XCTAssert(returnObject == TestConfig.expectedNullDataAddition)
  }
  
  func testDifferentDataType() {
    let publisher: AnyPublisher<Int, Error>? = self.state.subscribe(type: SwiftlySubscription.self,
                                                                          id: SwiftlyModule.SubjectIdentifiers.differentDataType)
    
    XCTAssert(publisher != nil)
    
    let originalObject: Int? = self.state.object(type: SwiftlySubscription.self,
                                                      id: SwiftlyModule.SubjectIdentifiers.differentDataType)

    XCTAssert(originalObject == TestConfig.initialDifferentDataType)
    
  }
  
  func testDifferentDataTypeWithAddition() {
    let publisher: AnyPublisher<Int, Error>? = self.state.subscribe(type: SwiftlySubscription.self,
                                                                          id: SwiftlyModule.SubjectIdentifiers.differentDataType)
    
    XCTAssert(publisher != nil)
    
    let originalObject: Int? = self.state.object(type: SwiftlySubscription.self,
                                                      id: SwiftlyModule.SubjectIdentifiers.differentDataType)

    XCTAssert(originalObject == TestConfig.initialDifferentDataType)
    
    let expectation = XCTestExpectation()
    
    var returnObject: Int?
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
    
    state.addToDifferentDataType()
    
    wait(for: [expectation], timeout: TestConfig.expectationTimeout)
    
    XCTAssertNotNil(returnObject, "Object was never set meaning there was an error: \(returnError?.localizedDescription ?? "")")
    XCTAssert(returnObject == TestConfig.expectedDifferentDataAddition)
    
  }
  
  func testInvalidDataType() {
    let publisher: AnyPublisher<Int?, Error>? = self.state.subscribe(type: SwiftlySubscription.self,
                                                                          id: SwiftlyModule.SubjectIdentifiers.differentDataType)
    
    XCTAssert(publisher == nil, "Publisher should be nil since there's no publisher with optional type Int")
  }
}
