//
//  FirestoreManager.swift
//  Homes
//
//  Created by William Vabrinskas on 8/29/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import FirebaseFirestore

enum Reference: Equatable {
  case users(id: String = "")
  case media(id: String = "")
  case feed(id: String = "")
  case comments(id: String = "")

  func ref(db: Firestore) -> DocumentReference {
    switch self {
    case let .users(id):
      return db.collection("users").document(id)
    case let .media(id):
      return db.collection("media").document(id)
    case let .feed(id):
      return db.collection("feeds").document(id)
    case let .comments(id: id):
      return db.collection("comments").document(id)
    }
  }
}

protocol FirebaseGeneralManager {
  func initialize()
}

extension FirebaseGeneralManager {
  func initialize() {
    FirebaseApp.initialize()
  }
}

protocol FirestoreManager {
  typealias FirebaseReturnBlock = (Result<Bool, Error>) -> ()

  var db: Firestore { get }
  
  typealias Setblock<T> = (_ result: Result<T, Error>) -> ()
  func setDoc<T: Encodable>(ref: Reference, value: T, complete: Setblock<Bool>?)
  func updateDoc(ref: Reference, value: [String: Any], complete: Setblock<Bool>?)
  func updateDoc<T: Encodable>(ref: Reference, value: T, complete: Setblock<Bool>?)
  func getDoc<T: Decodable>(ref: Reference, complete: @escaping Setblock<T>)
  func removeDoc(ref: Reference, complete: Setblock<Bool>?)
}

extension FirestoreManager {
  
  var db: Firestore {
    return Firestore.firestore()
  }
  
  func updateDoc(ref: Reference, value: [String: Any], complete: Setblock<Bool>?) {
    ref.ref(db: self.db).updateData(value) { (error) in
      guard error == nil else {
        print(error?.localizedDescription)
        complete?(.failure(error ?? CoordinatorError.invalidType))
        return
      }
      complete?(.success(true))
    }
  }
  
  func updateDoc<T: Encodable>(ref: Reference, value: T, complete: Setblock<Bool>?) {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(value)
      
      if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
        
        self.updateDoc(ref: ref, value: json, complete: complete)
        
      } else {
        complete?(.failure(CoordinatorError.invalidType))
      }
    } catch {
      print(error.localizedDescription)
      complete?(.failure(error))
    }
  }
  
  func removeDoc(ref: Reference, complete: Setblock<Bool>?) {
    
    ref.ref(db: self.db).delete { (error) in
      guard error == nil else {
        print(error?.localizedDescription)
        complete?(.failure(error ?? CoordinatorError.invalidType))
        return
      }
      complete?(.success(true))
    }
  }

  func setDoc<T: Encodable>(ref: Reference, value: T, complete: Setblock<Bool>?) {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(value)
      
      if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
        
        ref.ref(db: self.db).setData(json) { (error) in
          guard error == nil else {
            print(error?.localizedDescription)
            complete?(.failure(error ?? CoordinatorError.invalidType))
            return
          }
          
          complete?(.success(true))
        }
      } else {
        complete?(.failure(CoordinatorError.invalidType))
      }
    } catch {
      print(error.localizedDescription)
      complete?(.failure(error))
    }
  }
  
  func getDoc<T: Decodable>(ref: Reference, complete: @escaping (_ result: Result<T, Error>) -> ()) {
    ref.ref(db: self.db).getDocument { (snapshot, error) in
      guard let userDictionary = snapshot?.data() else {
        print("snapshot is not valid")
        complete(.failure(CoordinatorError.invalidType))
        return
      }
      
      do {
        let data = try JSONSerialization.data(withJSONObject: userDictionary, options: .prettyPrinted)
        let obj = try JSONDecoder().decode(T.self, from: data)
        complete(.success(obj))
        
      } catch {
        
        complete(.failure(error))
      }
      
    }
  }
}
