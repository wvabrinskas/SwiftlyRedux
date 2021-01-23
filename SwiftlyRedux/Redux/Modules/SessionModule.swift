
//  Created by William Vabrinskas on 9/11/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

//NOT SURE WHAT I WANT TO DO WITH THIS YET
class SessionModule: Module, FirebaseRealtimeManager {
  
  typealias ObjectType = RealtimeSession
  @Published var object: ObjectType?
  var objectPublisher: Published<ObjectType?>.Publisher { $object }
  
  public var realtimeSession: RealtimeSession? {
    didSet {
      self.object = realtimeSession
    }
  }
  
  enum UpdateType {
    case index
    case videoPlay
    case videoStop
    case videoSeek
  }
  
  public func keepSync(_ sessionKey: String) {
    self.observe(ref: .sessions(id: sessionKey)) { (result: Result<RealtimeSession?, Error>) in
      switch result {
      case let .success(session):
        self.realtimeSession = session
      case .failure(_):
        return
      }
    }
  }

  func setRealtimeSession(sessionKey: String, user: Profile?) {
    guard let user = user else {
      return
    }
        
    let members = [ user.userId ]
    
    let rtHome = RealtimeSession(id: sessionKey, members: members)
    
    self.setRealtime(ref: .sessions(id: sessionKey), value: rtHome)
  }
  
  func joinRealtimeSession(sessionKey: String,
                           user: Profile?,
                           complete: ((_ result: Result<RealtimeSession?, Error>) -> ())? = nil) {
    
    guard let user = user else {
      return
    }
    
    self.getRealtime(ref: .sessions(id: sessionKey)) { [weak self] (result: Result<RealtimeSession?, Error>) in
      
      switch result {
      case let .success(session):
        guard let home = session else {
          complete?(.failure(CoordinatorError.empty))
          return
        }
        
        var members = home.members
        members.append(user.userId)
        
        let newRTHome = RealtimeSession(id: home.id, members: members)
        
        self?.updateRealtime(ref: .sessions(id: sessionKey), value: newRTHome, complete: { (result) in
          switch result {
          case .success(_):
            complete?(.success(newRTHome))
          case let .failure(err):
            complete?(.failure(err))
          }
        })
        
      case let .failure(err):
        complete?(.failure(err))

      }
    }
  
  }

  func changeVideoPlayState(sessonKey: String, play: Bool, complete: ((_ result: Result<Bool, Error>) -> ())? = nil) {
    let updates = ["playVideo" : play]
  
    self.updateRealtime(ref: .sessions(id: sessonKey), value: updates, complete: complete)
  }
  
}
