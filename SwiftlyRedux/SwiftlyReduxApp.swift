//
//  SwiftlyReduxApp.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/22/21.
//

import SwiftUI
import Firebase

@main
struct SwiftlyReduxApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          FirebaseApp.configure()
        }
    }
  }
}
