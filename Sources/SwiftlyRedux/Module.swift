
//  Copyright © 2020 William Vabrinskas. All rights reserved.

import Foundation
import Combine


/// Type erased SubjectObservable holder. Used to store subject holders without the need for generics
public struct AnySubjectHolder {
  internal var subject: Any
  internal var genericPublisher: AnyPublisher<Any?, Error>
  
  internal init<T: SubjectObservable>(_ sub: T) {
    self.subject = sub
    self.genericPublisher = sub.objectPublisher.map({ $0 as Any }).eraseToAnyPublisher()
  }
}


/// Protocol defining how a subject can be observed by the `StateHolder` object. Contains the publisher, the passthrough subject, as well as its unique identifier for look up by the `Module`
public protocol SubjectObservable: AnyObject {
  associatedtype ObjectType
  associatedtype SubID: SubjectIdentifier
  
  /// the identifier for this particular observable subject
  var identifier: SubID { get }
  
  /// the object this observable subject is responsible for
  var object: ObjectType? { get set }
  
  /// the passthrough subject where all communication downstream is handled
  var objectSubject: PassthroughSubject<ObjectType, Error> { get }
  
  /// the publisher that objects can subscribe to to listen to updates to the object.
  var objectPublisher: AnyPublisher<ObjectType, Error> { get }
}

/// The base class for creating an object that can be observed downstream by the `StateHolder`. This normally isn't created directly rather created by the `Module` by calling `addSubject`. Conforms to `SubjectObservable`
public class SubjectHolder<ObjectType, SubID: SubjectIdentifier>: SubjectObservable {
  
  public var identifier: SubID
  public var object: ObjectType?
  
  public let objectSubject: PassthroughSubject<ObjectType, Error> = .init()
  public var objectPublisher: AnyPublisher<ObjectType, Error> {
    return objectSubject.eraseToAnyPublisher()
  }
  
  public init(identifier: SubID, object: ObjectType?) {
    self.object = object
    self.identifier = identifier
  }
}

/// Protocol defining how to create the identifiable id for the `SubjectHolder`. This should be some type of `RawRepresentable` where the `RawValue` conforms to `Equatable`
public protocol SubjectIdentifier: RawRepresentable where RawValue: Equatable {
  var stringValue: String { get }
  //TODO: figure out how to return type
}

/// The protocol that defines how the base `Module` objects should behave. This controls the flow of all logic pertaining to the `SubjectHolder`s. This class is reponsible for the updates to the subjects. Performs `CRUD` operations for `SubjectHolder`s
public protocol Module: ObservableObject {
  
  /// Current hash map of `AnySubjectHolder`s that this module contains
  var subjects: [String: AnySubjectHolder] { get set }
  
  /// Adds a subject to this module that can be updated and observed
  func addSubject<T, TID: SubjectIdentifier>(_ object: T, identifier: TID)
  
  /// Removes a subject from this module.
  func removeSubject<TID: SubjectIdentifier>(_ id: TID)
  
  /// Posts an update to the specified subject given by the ID with the value provided.
  func updateSubject<TValue, TID: SubjectIdentifier>(value: TValue, identifier: TID)
  
  /// Gets the subject specified by the id parameter
  /// - Returns: the `SubjectHolder` that maps to the id.
  func getSubject<T, TSubID: SubjectIdentifier>(id: TSubID) -> SubjectHolder<T, TSubID>?
}

public extension Module {
  
  /// Adds a subject to this module that can be updated and observed
  func addSubject<T, TID: SubjectIdentifier>(_ object: T, identifier: TID) {
    let subject = SubjectHolder(identifier: identifier, object: object)
    self.subjects[identifier.stringValue] = AnySubjectHolder(subject)
  }
  
  /// Removes a subject from this module.
  func removeSubject<TID: SubjectIdentifier>(_ id: TID) {
    self.subjects.removeValue(forKey: id.stringValue)
  }
  
  /// Gets the subject specified by the id parameter
  /// - Returns: the `SubjectHolder` that maps to the id.
  func getSubject<T, TSubID: SubjectIdentifier>(id: TSubID) -> SubjectHolder<T, TSubID>? {
    let sub = self.subjects[id.stringValue]
    return sub?.subject as? SubjectHolder<T, TSubID>
  }
  
  /// Posts an update to the specified subject given by the ID with the value provided.
  func updateSubject<TValue, TID: SubjectIdentifier>(value: TValue, identifier: TID) {
    let sub = self.subjects[identifier.stringValue]
    
    if let castSub = sub?.subject as? SubjectHolder<TValue, TID> {
      castSub.object = value
      castSub.objectSubject.send(value)
      return
    }
    
    print("SwiftlyRedux Error: Could not update subject as the value you provided doesn't match the type for the provided subject id. It's possible that you're expecting a non-optional value but passing in an optional value type to the generic typed value parameter.")
  }
}
