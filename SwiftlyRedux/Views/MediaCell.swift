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
  
  @State private var activeSheet: ButtonSheet?
  
  private enum ButtonSheet: Identifiable {
    case comments
    
    var id: Int { hashValue }
  }

  var body: some View {
    VStack(spacing: 5) {
      mediaVisualView()
        .shadow(color: Color(.sRGB, white: 0.0, opacity: 0.4), radius: 5, x: 0, y: 10)
      
      HStack {
        Image(systemName: "bubble.left")
          .resizable()
          .frame(width: 15, height: 15, alignment: .center)
          .aspectRatio(contentMode: .fit)
          .foregroundColor(theme.darkTextColor)
          .onTapGesture {
            self.activeSheet = .comments
          }
        
        Text("\(self.viewModel.media.comments.count)")
          .font(Font.system(size: 12))
          .fontWeight(.bold)
          .foregroundColor(theme.darkTextColor)
      }
      .padding(.top, 16)
      .padding(.leading, 16)
      .frame(maxWidth: .infinity, alignment: .leading)
      
      Text(self.viewModel.media.description)
        .font(Font.system(size: 15))
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.trailing, .leading], 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .foregroundColor(theme.darkTextColor)
      
    }
    .sheet(item: self.$activeSheet) { sheet in
      switch sheet {
      case .comments:
        CommentsView(viewModel: CommentsViewModel(media: viewModel.media))
      }
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

