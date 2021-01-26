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
  
  @State var media: MediaModule.ObjectType = []
  
  var viewModel: FeedViewModel
  
  var body: some View {
    UITableView.appearance().backgroundColor = .clear

    return List {
      ForEach(media, id: \.id) { mediaObj in
        MediaCell(viewModel: MediaCellViewModel(media: mediaObj))
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .listRowBackground(theme.secondaryBackground)
      Spacer()
        .listRowBackground(theme.secondaryBackground)
    }
    .background(theme.secondaryBackground).edgesIgnoringSafeArea(.all)
    .onAppear {
      self.state.getFeedMedia(feed: viewModel.feed)
    }
    .onReceive(state.subscribe(type: .media), perform: { (media: MediaModule.ObjectType?) in
      if let media = media {
        self.media = media
      }
    })
  }
}

