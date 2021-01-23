//
//  Coordinator.swift
//  Homes
//
//  Created by William Vabrinskas on 8/31/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import Combine

enum CoordinatorError: Error {
   case invalidType
   case empty
   
   var localizedDescription: String {
     switch self {
     case .invalidType:
       return "invalid type, cannot convert"
     case .empty:
       return "empty object error"
     }
   }
 }

protocol Module: ObservableObject {
  associatedtype ObjectType
  //Should be @Published in implementation, no way to do this yet in a protocol
  var object: ObjectType? { get set }
  var objectPublisher: Published<ObjectType?>.Publisher { get }
}
