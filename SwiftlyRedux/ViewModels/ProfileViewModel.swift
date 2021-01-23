import Foundation

struct ProfileViewModel {
  var image: String? = nil
  var firstname: String = ""
  var lastname: String = ""
  var uid: String
  var homes: [String] = []
  
  init(profile: Profile) {
    self.firstname = profile.firstName
    self.lastname = profile.lastName
    self.uid = profile.userId
    self.image = profile.profileImage
  }
}

