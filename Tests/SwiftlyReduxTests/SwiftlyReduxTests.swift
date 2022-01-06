import XCTest
import Combine
@testable import SwiftlyRedux


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
