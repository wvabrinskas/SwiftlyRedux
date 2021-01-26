import Foundation

struct ProfileViewModel {
  var image: String? = nil
  var firstname: String = ""
  var lastname: String = ""
  var uid: String
  var username: String
  var mediaCount: Int
  
  init(profile: Profile, feed: Feed) {
    self.firstname = profile.firstName
    self.lastname = profile.lastName
    self.uid = profile.userId
    self.image = profile.profileImage
    self.username = profile.username
    self.mediaCount = feed.media.count
  }
}

