
//  Copyright © 2020 William Vabrinskas. All rights reserved.

import Foundation
import Combine


public struct AnySubjectHolder {
  internal var subject: Any
  //internal var genericPassthrough: PassthroughSubject<Any?, Error>
  internal var genericPublisher: AnyPublisher<Any?, Error>
  
  internal init<T: SubjectObservable>(_ sub: T) {
    self.subject = sub
    self.genericPublisher = sub.objectPublisher.map({ $0 as Any }).eraseToAnyPublisher()
  }
}

public protocol SubjectObservable: AnyObject {
  associatedtype ObjectType
  associatedtype SubID: SubjectIdentifier
  
  var identifier: SubID { get }
  var object: ObjectType? { get set }
  
  var objectSubject: PassthroughSubject<ObjectType?, Error> { get }
  var objectPublisher: AnyPublisher<ObjectType?, Error> { get }
}

public class SubjectHolder<ObjectType, SubID: SubjectIdentifier>: SubjectObservable {
  
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
  //TODO: figure out how to return type
}

public protocol Module: ObservableObject {
  var subjects: [String: AnySubjectHolder] { get set }
  
  func addSubject<T, TID: SubjectIdentifier>(_ object: T?, identifier: TID)
  func removeSubject<TID: SubjectIdentifier>(_ id: TID)
  func updateSubject<TValue, TID: SubjectIdentifier>(value: TValue?, identifier: TID)
  func getSubject<T, TSubID: SubjectIdentifier>(id: TSubID) -> SubjectHolder<T, TSubID>?
}

public extension Module {
  func addSubject<T, TID: SubjectIdentifier>(_ object: T?, identifier: TID) {
    let subject = SubjectHolder(identifier: identifier, object: object)
    self.subjects[identifier.stringValue] = AnySubjectHolder(subject)
  }
  
  func removeSubject<TID: SubjectIdentifier>(_ id: TID) {
    self.subjects.removeValue(forKey: id.stringValue)
  }
  
  func getSubject<T, TSubID: SubjectIdentifier>(id: TSubID) -> SubjectHolder<T, TSubID>? {
    let sub = self.subjects[id.stringValue]
    return sub?.subject as? SubjectHolder<T, TSubID>
  }
  
  func updateSubject<TValue, TID: SubjectIdentifier>(value: TValue?, identifier: TID) {
    let sub = self.subjects[identifier.stringValue]
    
    if let castSub = sub?.subject as? SubjectHolder<TValue, TID> {
      castSub.object = value
      
      if let value = value {
        castSub.objectSubject.send(value)
      }
    }
  }
}
