//
//  MediaCell.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/25/21.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI

struct MediaCell: View {
  var viewModel: MediaCellViewModel
  @Environment(\.state) var state
  @Environment(\.theme) var theme

  var body: some View {
    VStack(spacing: 5) {
      mediaVisualView()
        .shadow(color: Color(.sRGB, white: 0.0, opacity: 0.4), radius: 5, x: 0, y: 10)
      
      Text(self.viewModel.media.description)
        .font(Font.system(size: 15))
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.trailing, .leading], 16)
        .padding([.top], 8)
        .padding(.bottom, 16)
        .foregroundColor(theme.darkTextColor)
      
    }
    .background(theme.cellColor)
    .cornerRadius(25)
  }
  
  func mediaVisualView() -> AnyView {
    let url = self.viewModel.media.url

    switch viewModel.media.type {
    case .photo:
      
      return
        AnyView(
          WebImage(url: URL(string: url))
        .resizable()
        .placeholder {
          Color.lightSlateGray
        }
        .indicator(.activity)
        .aspectRatio(16/9, contentMode: .fit)
        .cornerRadius(25))
      
    case .video:
      guard let videoUrl = URL(string: url) else {
        return AnyView(theme.background)
      }
      return
        AnyView(VideoPlayer(player: AVPlayer(url: videoUrl))
                  .aspectRatio(16/9, contentMode: .fit)
                  .cornerRadius(25))

    }
  }
  
  private func getMediaId() -> String {
    self.state.getVideoId(for: self.viewModel.media.url) ?? ""
  }
}

