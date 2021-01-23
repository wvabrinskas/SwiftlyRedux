//
//  FirebaseManager.swift
//  Homes
//
//  Created by William Vabrinskas on 8/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase

public enum RTReference: Equatable {
  case sessions(id: String = "")
  
  func ref(base: DatabaseReference) -> DatabaseReference {
    switch self {
    case let .sessions(id):
      return base.child("sessions").child(id)
    }
  }
}

public protocol FirebaseRealtimeManager {
  var baseRef: DatabaseReference { get }
  typealias Setblock<T> = (_ result: Result<T, Error>) -> ()
  func observe<T: Decodable>(ref: RTReference, complete: @escaping Setblock<T>)
  func updateRealtime<T: Encodable>(ref: RTReference, value: T, complete: Setblock<Bool>?)
  func updateRealtime(ref: RTReference, value: [String: Any], complete: Setblock<Bool>?)
  func setRealtime<T: Encodable>(ref: RTReference, value: T, complete: Setblock<Bool>?)
  func getRealtime<T: Decodable>(ref: RTReference, complete: @escaping Setblock<T>)
}

extension FirebaseRealtimeManager {
  var baseRef: DatabaseReference {
    return Database.database().reference()
  }
  
  func observe<T: Decodable>(ref: RTReference, complete: @escaping Setblock<T>) {
    let ref = ref.ref(base: self.baseRef)
    ref.observe(.value) { (snapshot) in
      let result: Result<T, Error> = self.decode(snapshot: snapshot)
      complete(result)
    }
  }
  
  func updateRealtime<T: Encodable>(ref: RTReference, value: T, complete: Setblock<Bool>? = nil) {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(value)
      
      if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
  
        self.updateRealtime(ref: ref, value: json, complete: complete)
        
      } else {
        complete?(.failure(CoordinatorError.invalidType))
      }
      
    } catch {
      print(error.localizedDescription)
      complete?(.failure(error))
    }
  }
  
  func updateRealtime(ref: RTReference, value: [String: Any], complete: Setblock<Bool>? = nil) {
    ref.ref(base: self.baseRef).updateChildValues(value) { (error, reference) in
      guard error == nil else {
        complete?(.failure(error ?? CoordinatorError.invalidType))
        return
      }
      complete?(.success(true))
    }
  }
  
  func setRealtime<T: Encodable>(ref: RTReference, value: T, complete: Setblock<Bool>? = nil) {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(value)
      let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
      
      ref.ref(base: self.baseRef).setValue(json) { (error, ref) in
        guard error == nil else {
          print(error?.localizedDescription)
          complete?(.failure(error ?? CoordinatorError.invalidType))
          return
        }
        complete?(.success(true))
      }
      
    } catch {
      print(error.localizedDescription)
      complete?(.failure(error))
    }
  }
  
  func getRealtime<T: Decodable>(ref: RTReference, complete: @escaping Setblock<T>) {
    
    ref.ref(base: self.baseRef).observeSingleEvent(of: .value) { (snapshot) in
      let result: Result<T, Error> = self.decode(snapshot: snapshot)
      complete(result)
    }
  }
  
  private func decode<T: Decodable>(snapshot: DataSnapshot) -> Result<T, Error> {
    guard let userDictionary = snapshot.value as? [String: AnyHashable?] else {
      print("snapshot: \(snapshot.value) is not valid")
      return .failure(CoordinatorError.invalidType)
    }
    
    do {
      let data = try JSONSerialization.data(withJSONObject: userDictionary, options: .prettyPrinted)
      let obj = try JSONDecoder().decode(T.self, from: data)
      
      return .success(obj)
      
    } catch {
      return .failure(error)
    }
  }
}
