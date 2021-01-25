//
//  PlayerView.swift
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import SwiftUI
import YouTubePlayer

struct PlayerView: UIViewRepresentable {
  public let viewModel: PlayerViewModel
  @Environment(\.state) var state

  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    if let view = uiView as? YouTubePlayerView {
      view.playerVars = ["playsinline" : 1 as AnyObject, "controls": 1 as AnyObject]
      //if view.ready == false {
        view.loadVideoID(viewModel.videoId)
      //}

      if let _: Profile = self.state.object(type: .auth) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          if self.viewModel.play {
            view.play()
          } else {
            view.stop()
          }
        }
      }
    }
  }
  
  func makeUIView(context: Context) -> UIView {
    var view = YouTubePlayerView(frame: .zero)
    view.playerVars = ["playsinline" : 1 as AnyObject, "controls": 1 as AnyObject]
    self.state.setVideoDelegate(&view)
    return view
  }
}

