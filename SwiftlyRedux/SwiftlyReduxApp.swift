//
//  SwiftlyReduxApp.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/22/21.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    print("Your code here")
    return true
  }
}

@main
struct SwiftlyReduxApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.state) var state
  
  var body: some Scene {
    WindowGroup {
      //EXAMPLE: can check state at launch to show a new view
//      if state.hasCachedValidUser() {
//        ContentView()
//      } else {
//        LoginView()
//      }
      
      
      HomePageView()
    }

  }
}
