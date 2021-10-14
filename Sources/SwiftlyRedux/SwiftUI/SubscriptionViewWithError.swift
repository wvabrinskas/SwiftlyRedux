//
//  File.swift
//  
//
//  Created by William Vabrinskas on 10/14/21.
//

import Foundation
import SwiftUI
import Combine

public struct SubscriptionViewWithError<Content: View>: View {
  
  private var content: Content
  private var cancellable: AnyCancellable
  
  public init<TType, TError>(_ content: Content,
                      _ publisher: AnyPublisher<TType, TError>,
                      value: @escaping (_ value: TType) -> (),
                      error: @escaping (_ error: TError) -> ()) {
    
    let cancellable = publisher
      .receive(on: DispatchQueue.main)
      .sink { subError in
        switch subError {
        case .failure(let newError):
          error(newError)
        case .finished:
          print("")
        }
      } receiveValue: { gotValue in
        value(gotValue)
      }
    
    self.content = content
    self.cancellable = cancellable
  }
  
  public var body: some View {
    self.content
  }
  
}

public extension View {
  func onRecieveWithError<TType, TError>(_ publisher: AnyPublisher<TType, TError>,
                                         value: @escaping (_ value: TType) -> (),
                                         error: @escaping (_ error: TError) -> ()) -> some View {
  
    return SubscriptionViewWithError(self, publisher, value: value, error: error)
  }
}
