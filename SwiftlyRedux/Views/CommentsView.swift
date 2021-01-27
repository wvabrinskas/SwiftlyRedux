//
//  FeedView.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/25/21.
//

import SwiftUI

struct CommentsView: View {
  @Environment(\.state) var state
  @Environment(\.theme) var theme
  @Environment(\.presentationMode) var mode

  @State var comments: CommentsModule.ObjectType = []
  @State var newComment: String = ""
  @State var postingComment: Bool = false
  
  var viewModel: CommentsViewModel
  
  var body: some View {
    UITableView.appearance().backgroundColor = .clear
    return VStack {
      HeaderView(viewModel: HeaderViewModel(title: "Comments"))
        .padding(.top, 40)
      
      List {
        ForEach(comments, id: \.id) { comment in
          CommentCell(viewModel: CommentCellViewModel(comment: comment))
            .shadow(color: Color(.sRGB, white: 0.0, opacity: 0.4), radius: 5, x: 0, y: 0)
        }
        .onDelete(perform: self.deleteItem(at:))
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(theme.secondaryBackground)
        Spacer()
          .listRowBackground(theme.secondaryBackground)
      }
      HStack {
        ClosableTextField(viewModel: CloseableTextFieldViewModel(buttonTitle: "close",
                                                                 placeholder: "new comment",
                                                                 placeholderColor: .systemGray,
                                                                 textSize: 20,
                                                                 textAlignment: .left,
                                                                 textColor: theme.lightTextColor.uiColor()),
                          text: self.$newComment,
                          keyType: .default)
        
        let viewModel = ButtonViewModel(buttonImage: "paperplane",
                                        size: CGSize(width: 40, height: 40),
                                        backgroundColor: Color.seaGreen,
                                        imageColor: theme.lightTextColor,
                                        imageSize: 20)
        AnyView(ButtonView(viewModel: viewModel) {
          self.postComment()
        })
      }
      .frame(width: 400, height: 30)
      .padding(.bottom, 100)
      .padding([.leading, .trailing], 16)
    }
    .background(theme.secondaryBackground).edgesIgnoringSafeArea(.all)
    .onAppear {
      self.state.getComments(media: self.viewModel.media)
    }
    .onReceive(state.subscribe(type: .comment), perform: { (comments: CommentsModule.ObjectType?) in
      if let comments = comments {
        self.comments = comments
      }
    })
    .loadable(title: "posting...",
              showing: self.$postingComment,
              background: theme.secondaryBackground,
              textColor: theme.lightTextColor)
  }
  
  private func deleteItem(at indexSet: IndexSet) {
    indexSet.forEach { (index) in
      if index < self.comments.count {
        let comment = self.comments[index]
        self.state.removeComment(comment: comment, from: self.viewModel.media) { (result) in
          print(result)
        }
      }
    }
  }
  
  private func postComment() {
    guard self.newComment.count > 0, !self.newComment.isEmpty else {
      return
    }
    
    self.postingComment = true
    
    self.state.addComment(comment: self.newComment, to: self.viewModel.media) { (result) in
      DispatchQueue.main.async {
        self.postingComment = false
      }
    }
  }
}

