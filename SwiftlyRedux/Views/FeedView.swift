//
//  FeedView.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/25/21.
//

import SwiftUI

struct FeedView: View {
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  
  @State var media: [Media] = []
  
  var viewModel: FeedViewModel
  
  var body: some View {
    List {
      ForEach(media, id: \.id) { mediaObj in
        MediaCell(viewModel: MediaCellViewModel(media: mediaObj))
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .listRowBackground(theme.secondaryBackground)
    }
    .onAppear {
      self.state.getFeed(feed: viewModel.feed)
    }
    .onReceive(state.subscribe(type: .media), perform: { (media: MediaModule.ObjectType?) in
      if let media = media {
        self.media = media
      }
    })
    .background(theme.secondaryBackground).edgesIgnoringSafeArea(.all)
  }
}

