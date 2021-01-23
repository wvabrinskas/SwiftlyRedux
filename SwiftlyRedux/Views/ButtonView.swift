//
//  ButtonView.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import SwiftUI


struct ButtonView: View {
  public let viewModel: ButtonViewModel
  public let action: () -> ()
  
  @Environment(\.theme) var theme

  var body: some View {
    VStack {
      Button(action: self.action) {
        Image(systemName: viewModel.buttonImage)
        .resizable()
        .aspectRatio(contentMode: .fit)
          .frame(width: viewModel.imageSize)
          .foregroundColor(viewModel.imageColor)
      }
      .frame(width: viewModel.size.width, height: viewModel.size.height)
      .background(viewModel.backgroundColor)
      .cornerRadius(150)
      .shadow(radius: viewModel.shadow == true ? viewModel.shadowRadius : 0)
      
      Text(viewModel.title.lowercased())
        .foregroundColor(.black)
        .fontWeight(.bold)
        .font(Font.system(size: 20))
        .padding([.top], 3)
    }
  }
}

