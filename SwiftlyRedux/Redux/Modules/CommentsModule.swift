//
//  CommentsModule.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/27/21.
//

import Foundation


class CommentsModule: Module, FirestoreManager, FireStorageManager {

  typealias ObjectType = [Comment]
  
  public enum CommentError: Error {
    case containsError, nonExistError
    
    var localizedDescription: String {
      switch self {
      case .containsError:
        return "Cannot post the same comment object twice"
      case .nonExistError:
        return "Comment does not exist"
      }
    }
  }
  
  @Published var object: ObjectType?
  var objectPublisher: Published<ObjectType?>.Publisher { $object }
  
  func getComments(id: String) {
    self.getDoc(ref: .comments(id: id)) { (result: Result<ObjectType, Error>) in
      switch result {
      case let .success(comments):
        self.object = comments
      case let .failure(error):
        self.object = []
        print(error)
      }
    }
  }
  
  func removeComment(comment: Comment, from media: Media, complete: FirebaseReturnBlock?) {
    guard let obj = self.object, obj.contains(comment) else {
      complete?(.failure(CommentError.nonExistError))
      return
    }
    
    self.removeDoc(ref: .comments(id: comment.id)) { [weak self] (result) in
      switch result {
      case .success:
        let updatedComments = obj.filter({ $0 != comment })
        
        let updates: [String: Any] = ["comments" : updatedComments]
        
        //remove comment from media
        self?.updateDoc(ref: .media(id: media.id), value: updates) { [weak self] (updateResult) in
          switch updateResult {
          case .success:
                        
            self?.object = updatedComments.sorted(by: { $0.postedDate > $1.postedDate })
            complete?(.success(true))

          case let .failure(error):
            complete?(.failure(error))
          }
        }
        
        complete?(.success(true))
      case let .failure(error):
        complete?(.failure(error))
      }
    }
  }
  
  func addComment(comment: Comment, to media: Media, complete: FirebaseReturnBlock?) {
    var oldComments = media.comments
    
    guard !oldComments.contains(comment.id) else {
      complete?(.failure(CommentError.containsError))
      return
    }
    //add comment to comments database
    self.setDoc(ref: .comments(id: comment.id), value: comment) { [weak self] (result) in
      switch result {
      case .success:
        
        //add comments to media object by first pulling the old ones and appending
        oldComments.append(comment.id)
        
        let updates: [String: Any] = ["comments" : oldComments]
        
        //if media upload successful, update the feed d50ocument
        self?.updateDoc(ref: .media(id: media.id), value: updates) { [weak self] (updateResult) in
          switch updateResult {
          case .success:
            
            var oldCommentObjects = self?.object
            oldCommentObjects?.append(comment)
            
            self?.object = oldCommentObjects?.sorted(by: { $0.postedDate > $1.postedDate })
            complete?(.success(true))

          case let .failure(error):
            //we don't need to set a doc on failure because you can only comment on a media
            //object that already exists in the database
            complete?(.failure(error))
          }
        }
        
      case let .failure(error):
        complete?(.failure(error))
      }
    }
  }

}
