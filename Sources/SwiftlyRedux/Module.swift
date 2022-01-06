
//  Copyright © 2020 William Vabrinskas. All rights reserved.

import Foundation
import Combine


public struct AnySubject {
  internal var subject: Any
  
  internal init<T: SomeSubject>(_ sub: T) {
    self.subject = sub
  }
}

public protocol SomeSubject: AnyObject {
  associatedtype ObjectType
  associatedtype SubID: SubjectIdentifier
  
  var identifier: SubID { get }
  var object: ObjectType? { get set }
  
  var objectSubject: PassthroughSubject<ObjectType?, Error> { get }
  var objectPublisher: AnyPublisher<ObjectType?, Error> { get }
}

public class Subject<ObjectType, SubID: SubjectIdentifier>: SomeSubject {
  
  public var identifier: SubID
  public var object: ObjectType?
  
  public let objectSubject: PassthroughSubject<ObjectType?, Error> = .init()
  public var objectPublisher: AnyPublisher<ObjectType?, Error> {
    return objectSubject.eraseToAnyPublisher()
  }
  
  public init(identifier: SubID, object: ObjectType?) {
    self.object = object
    self.identifier = identifier
  }
}

public protocol SubjectIdentifier: RawRepresentable where RawValue: Equatable {
  var stringValue: String { get }
}

public protocol Module: ObservableObject {
  var subjects: [String: AnySubject] { get set }
  
  func addSubject<T, TID: SubjectIdentifier>(_ object: T, identifier: TID)
  func removeSubject<TID: SubjectIdentifier>(_ id: TID)
  func updateSubject<TValue, TID: SubjectIdentifier>(value: TValue?, identifier: TID)
  func getSubject<T, TSubID: SubjectIdentifier>(id: TSubID) -> Subject<T, TSubID>?
}

public extension Module {
  func addSubject<T, TID: SubjectIdentifier>(_ object: T, identifier: TID) {
    let subject = Subject(identifier: identifier, object: object)
    self.subjects[identifier.stringValue] = AnySubject(subject)
  }
  
  func removeSubject<TID: SubjectIdentifier>(_ id: TID) {
    self.subjects.removeValue(forKey: id.stringValue)
  }
  
  func getSubject<T, TSubID: SubjectIdentifier>(id: TSubID) -> Subject<T, TSubID>? {
    let sub = self.subjects[id.stringValue]
    return sub?.subject as? Subject<T, TSubID>
  }
  
  func updateSubject<TValue, TID: SubjectIdentifier>(value: TValue?, identifier: TID) {
    let sub = self.subjects[identifier.stringValue]
    
    if let castSub = sub?.subject as? Subject<TValue, TID> {
      castSub.object = value
      
      if let value = value {
        castSub.objectSubject.send(value)
      }
    }
  }
}
