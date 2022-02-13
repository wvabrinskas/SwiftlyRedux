//  Copyright © 2020 William Vabrinskas. All rights reserved.
import Foundation
import Combine

public enum SubscriptionError: LocalizedError {
  case publisherNonExistant
  
  public var errorDescription: String? {
    var error = ""
    
    switch self {
      case .publisherNonExistant:
        error = "Publisher does not exist"
    }
    
    return NSLocalizedString(error, comment: "SubscriptionError")
  }
}
/// A proxy object that manages the connection between the `StateHolder` and a given `Module`
public protocol StateSubscription: AnyObject {
  associatedtype TModule: Module
  var cancellables: Set<AnyCancellable> { get set }
  
  /// `Module` that this subscription is providing to the state
  var module: TModule { get }
  
  /// Object from the `SubjectObservable` given by the `SubjectIdentifier`
  /// - Returns: The object of type `TValue`
  func obj<TID: SubjectIdentifier, TValue>(id: TID) -> TValue?
  
  /// Publisher of type `AnyPublisher` from the `SubjectObservable` given by the `SubjectIdentifier`
  /// - Returns: The publisher of type `AnyPublisher<TValue, Error>?`
  func publisher<TID: SubjectIdentifier, TValue>(id: TID) -> AnyPublisher<TValue?, Error>?
  
  func on<TID: SubjectIdentifier, TValue>(id: TID,
                                          complete: ((Error?) -> ())?,
                                          recieve: ((TValue) -> ())?)
}

public extension StateSubscription {
  
  func on<TID: SubjectIdentifier, TValue>(id: TID,
                                          complete: ((Error?) -> ())? = nil,
                                          recieve: ((TValue) -> ())? = nil) {
    
    guard let pub: AnyPublisher<TValue, Error> = publisher(id: id) else {
      complete?(SubscriptionError.publisherNonExistant)
      return
    }
    
    pub.sink(receiveCompletion: { response in
      switch response {
      case .failure(let error):
          complete?(error)
      case .finished:
        complete?(nil)
      }
    }, receiveValue: { value in
      recieve?(value)
    })
      .store(in: &cancellables)
  }
  
  /// Object from the `SubjectObservable` given by the `SubjectIdentifier`
  /// - Returns: The object of type `TValue`
  func obj<TID: SubjectIdentifier, TValue>(id: TID) -> TValue? {
    let subject: SubjectHolder<TValue, TID>? = self.module.getSubject(id: id)
    return subject?.object
  }
  
  /// Publisher of type `AnyPublisher` from the `SubjectObservable` given by the `SubjectIdentifier`
  /// - Returns: The publisher of type `AnyPublisher<TValue, Error>?`
  func publisher<TID: SubjectIdentifier, TValue>(id: TID) -> AnyPublisher<TValue, Error>? {
    let obj = self.module
    return obj.getSubject(id: id)?.objectPublisher
  }
}
