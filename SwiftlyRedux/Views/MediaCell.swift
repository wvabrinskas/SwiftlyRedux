//
//  MediaCell.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/25/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct MediaCell: View {
  var viewModel: MediaCellViewModel
  @Environment(\.state) var state
  @Environment(\.theme) var theme

  var body: some View {
    VStack(spacing: 5) {
      mediaVisualView()
      
      Text(self.viewModel.media.description)
        .font(Font.system(size: 22))
        .fontWeight(.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.trailing, .leading], 16)
        .padding(.top, 8)
        .foregroundColor(theme.lightTextColor)
      
    }
    .background(theme.secondaryBackground)
  }
  
  func mediaVisualView() -> AnyView {
    
    switch viewModel.media.type {
    case .photo:
      let url = self.viewModel.media.url
      
      return
        AnyView(
          WebImage(url: URL(string: url))
        .resizable()
        .placeholder {
          Color.lightSlateGray
        }
        .indicator(.activity)
        .aspectRatio(16/9, contentMode: .fit))
      
    case .video:
      return
        AnyView(PlayerView(viewModel: PlayerViewModel(videoId: getMediaId(),
                                            play: false))
                  .aspectRatio(16/9, contentMode: .fit))
    }
  }
  
  private func getMediaId() -> String {
    self.state.getVideoId(for: self.viewModel.media.url) ?? ""
  }
}

