
//  Copyright © 2020 William Vabrinskas. All rights reserved.

import Foundation
import Combine

public protocol Subject: Hashable {
  associatedtype ObjectType
  associatedtype SubID: SubjectIdentifier
  
  var identifier: SubID { get }
  var object: ObjectType? { get set }
  var objectSubject: PassthroughSubject<ObjectType, Error> { get }
  var objectPublisher: AnyPublisher<ObjectType, Error> { get }
}

public protocol SubjectIdentifier: RawRepresentable where RawValue: Equatable {}

public protocol Module: ObservableObject {
  associatedtype Sub: Subject
  var subjects: Set<Sub> { get set }
  
  func addSubject(sub: Sub)
  func removeSubject(sub: Sub)
  func getSubject(id: Sub.SubID) -> Sub?
}

public extension Module {
  func addSubject(_ subject: Sub) {
    self.subjects.insert(subject)
  }
  
  func removeSubject(_ subject: Sub) {
    self.subjects.remove(subject)
  }
  
  func getSubject(id: Sub.SubID) -> Sub? {
    self.subjects.first(where: { $0.identifier == id })
  }
}

public extension Subject {
  var objectPublisher: AnyPublisher<ObjectType, Error> {
    return objectSubject.eraseToAnyPublisher()
  }
}
