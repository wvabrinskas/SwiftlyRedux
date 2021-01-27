//
//  CommentCell.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/27/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct CommentCell: View {
  var viewModel: CommentCellViewModel
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  
  var body: some View {
    HStack {
      getProfileImage()
        .frame(width: 80, height: 80)
      
      VStack(spacing: 6) {
        Text("\(self.viewModel.comment.posterUsername.lowercased()) says...")
          .font(Font.system(size: 10))
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding([.trailing], 16)
          .padding(.top, 8)
          .foregroundColor(Color.gray)
        
        Text(self.viewModel.comment.comment)
          .font(Font.system(size: 15))
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding([.trailing], 16)
          .padding(.bottom, 16)
          .foregroundColor(theme.darkTextColor)
      }
      
    }
    .frame(height: 100)
    .background(theme.commentsCellColor)
    .cornerRadius(25)
  }
  
  func getProfileImage() -> AnyView {
    guard let url = viewModel.comment.posterImage else {
      return AnyView(Color.lightSlateGray.clipShape(Circle()))
    }
    return
      
      AnyView(
      WebImage(url: URL(string: url))
      .resizable()
      .placeholder {
        Color.lightSlateGray
      }
      .indicator(.activity)
      .aspectRatio(16/9, contentMode: .fit)
      .clipShape(Circle())
      .transition(.fade(duration: 0.5))
      )
  }
}
